#include <vector>
#include <sstream>
#include <thread>
#include "../include/connectionHandler.h"
#include "../include/User.h"
#include <mutex>

using namespace std;

/**
* This code assumes that the server replies the elogin 127.0.0.1:7000 tomer 1234
xact text the client sent it (as opposed to the practical session example)
*/

class KeyBoardCommunicate{
private:
    ConnectionHandler &connectionHandler;
    User& user;

    //mutex& _mutex;
public:
    KeyBoardCommunicate(ConnectionHandler &connectionHandler, User& user) : connectionHandler(connectionHandler), user(user){}

    void operator()(){

        while (!connectionHandler.isLoggedOut()) {

            vector<string> input;
            string s, t;
            getline(cin, s);
            stringstream X(s);

            while (getline(X, t, ' '))input.push_back(t);

            if(input.size()==0)
                continue;

            string command = input.at(0);
          //  vector<string> output;

            if ((input.size()==4) && ((command == "login"))) {

                //user.setName(input.at(2));

                string output="CONNECT\n";
                output=output+"accept-version:1.2\n";
                output=output+"host:stomp.cs.bgu.ac.il\n";
                output=output+"login:"+input.at(2)+"\n";
                output=output+"passcode:"+input.at(3)+"\n";
                output=output+"\n";
           //     output=output+'\u0000';

                connectionHandler.sendFrameAscii(output, '\u0000');

                while (!connectionHandler.getLockerLogin()){
                }

                connectionHandler.lockLogin();
            }

            if (input.size()==2 && command == "join") {

                user.addRec(0, input.at(1));

                string output="SUBSCRIBE\n";
                output=output+"destination:" + input.at(1)+"\n";
                output=output+"id:" + user.addIdSub(input.at(1))+"\n";
                output=output+"receipt:" + user.getRecIdAndIncrement()+"\n";
                output=output+"\n";
               // output=output+'\u0000';

                connectionHandler.sendFrameAscii(output, '\u0000');
            }

            if (input.size()==2 && ((command == "exit") & (user.amISubscribeTo(input.at(1))))) {

                user.addRec(1, input.at(1));

                string output="UNSUBSCRIBE\n";
                output=output+"destination:" + input.at(1)+"\n";
                output=output+"id:" + user.getSubId(input.at(1))+"\n";
                output=output+"receipt:" + user.getRecIdAndIncrement()+"\n";
                output=output+"\n";
                //output=output+'\u0000';

                connectionHandler.sendFrameAscii(output, '\u0000');
            }

            if (input.size()==3 &&command == "add") {

                user.addBook(input.at(1), input.at(2));

                string output="SEND\n";
                output=output+"destination:" + input.at(1)+"\n";
                output=output+"\n";
                output=output+user.getName() + " has added the book " + input.at(2)+"\n";
                //output=output+'\u0000';

                connectionHandler.sendFrameAscii(output, '\u0000');
            }

            if (input.size()==3 && command == "borrow") {

                user.addToWishList(input.at(2));

                string output="SEND\n";
                output=output+"destination:" + input.at(1)+"\n";
                output=output+"\n";
                output=output+user.getName() + " wish to borrow " + input.at(2)+"\n";
               // output=output+'\u0000';

                connectionHandler.sendFrameAscii(output, '\u0000');
            }

            if (input.size()==3 && command == "return") {
                if(user.hasBook(input.at(1), input.at(2)) & user.borrowedBook(input.at(2))) {

                    string output="SEND\n";
                    output=output+"destination:" + input.at(1)+"\n";
                    output=output+"\n";
                    output=output+"Returning " + input.at(2) + " to " + user.returnBook(input.at(2))+"\n";
                   // output=output+'\u0000';

                    user.removeBookFromInventory(input.at(1), (input.at(2)));

                    connectionHandler.sendFrameAscii(output, '\u0000');
                }
            }

            if (input.size()==2 &&command == "status") {

                string output="SEND\n";
                output=output+"destination:" + input.at(1)+"\n";
                output=output+"\n";
                output=output+"book status"+"\n";
              //  output=output+'\u0000';

                connectionHandler.sendFrameAscii(output, '\u0000');
            }

            if (command == "logout") {

                string a="a";
                string output="DISCONNECT\n";
                user.addRec(2, a);
                output=output+"receipt:"+user.getRecIdAndIncrement()+"\n";
                output=output+"\n";
                //output=output+'\u0000';

                connectionHandler.sendFrameAscii(output, '\u0000');

                while (!connectionHandler.getLockerLogout()){
                }

               connectionHandler.lockLogout();

            }
        }
    }
};

class ServerCommunicate{
private:
    ConnectionHandler &connectionHandler;
    User& user;

   // mutex& _mutex;
public:
    ServerCommunicate(ConnectionHandler &connectionHandler, User& user) : connectionHandler(connectionHandler), user(user){}

    void operator()(){

        while (!connectionHandler.isLoggedOut()){
            ;
            string message;
            connectionHandler.getFrameAscii(message, '\0');
            vector<string> frameVector;
            istringstream ss(message);
            string token;

            while (getline(ss, token, '\n')){
                frameVector.push_back(token);
            }

            string command = frameVector.at(0);

            if (command == "ERROR"){
                cout << frameVector.at(2) << '\n';
                connectionHandler.logout();
                connectionHandler.close();
                connectionHandler.setLockerLogin();
            }

            if (command == "CONNECTED"){
                cout <<"Login successful" << '\n';
                connectionHandler.setLockerLogin();
            }

            if (command == "RECEIPT"){
                int recId = stoi(frameVector.at(1).substr(11, frameVector.at(1).length()-11));
                string topic = user.getTopicByRec(recId);
                int type = user.getTypeByRec(recId);
                if(type==0){
                    cout <<"Joined club "+topic << '\n';
                }
                if(type==1){
                    cout <<"Exited club "+topic << '\n';
                    user.leaveTopic(topic);
                }
                if(type==2){
                    connectionHandler.logout();
                    connectionHandler.close();
                    cout <<"Logout successful" << '\n';
                    connectionHandler.setLockerLogout();
                }
            }

            if (command == "MESSAGE"){
                string body = frameVector.at(5);
                string topic = frameVector.at(1).substr(12, frameVector.at(1).length()-11);
                vector<string> bodyVector;
                istringstream sp(body);
                string token2;

                while (getline(sp, token2, ' ')){
                    bodyVector.push_back(token2);
                }
                if (body == "book status"){

                    cout << topic + ":"+ body << '\n';

                    string output="SEND\n";
                    output=output+"destination:"+topic+"\n";
                    output=output+"\n";
                    output=output+user.myBooksOf(topic)+"\n";
                 //  output=output+'\u0000';

                    connectionHandler.sendFrameAscii(output, '\u0000');
                }
                else if (bodyVector.at(0)=="Returning"&&bodyVector.at(3)==user.getName()){
                    cout << topic+":"+body << '\n';
                    user.addBook(topic, bodyVector.at(1));
                }
                else if (bodyVector.size()>=2 && bodyVector.at(1)=="wish"){
                    cout << topic+":"+body << '\n';
                    string book = bodyVector.at(4);
                    if(user.hasBook(topic, book)){

                        string output="SEND\n";
                        output=output+"destination:"+topic+"\n";
                        output=output+"\n";
                        output=output+user.getName()+" has "+bodyVector.at(4)+"\n";
                        //output=output+'\u0000';

                        connectionHandler.sendFrameAscii(output, '\u0000');
                    }
                }
                else if(bodyVector.size()>=2 && bodyVector.at(1)=="has" && user.isAtMyWishList(bodyVector.at(2))){
                    cout << topic+":"+body << '\n';
                    user.deleteFromWishList(bodyVector.at(2));
                    user.addBook(topic, bodyVector.at(2));
                    user.addBorrow(bodyVector.at(2), bodyVector.at(0));

                    string output="SEND\n";
                    output=output+"destination:"+topic+"\n";
                    output=output+"\n";
                    output=output+"Taking "+bodyVector.at(2)+" from "+bodyVector.at(0)+"\n";
                    //output=output+'\u0000';

                    connectionHandler.sendFrameAscii(output, '\u0000');

                }

                else if(bodyVector.size()>=1 &&bodyVector.at(0)=="Taking" && bodyVector.at(3)==user.getName()){
                    cout << topic+":"+body << '\n';
                    user.removeBookFromInventory(topic, bodyVector.at(1));
                }
                else if(bodyVector.size()>=2 && bodyVector.at(1)=="has"){
                    cout << topic+":"+body << '\n';
                }
                else{
                    cout << body << '\n';
                }
            }
        }
    }
};

int main (int argc, char *argv[]) {



        bool sentLogin = false;
        vector<string> input;

        while (!sentLogin) {
            string s, t;
            getline(cin, s);
            stringstream X(s);

            while (getline(X, t, ' '))input.push_back(t);

            if (input.size() == 4 && input.at(0) == "login") {
                sentLogin = true;
            }
            else {
                input.clear();
            }
        }

        int indexOfColon = input.at(1).find_first_of(':');
        std::string host = input.at(1).substr(0, indexOfColon);
        short port = stoi(input.at(1).substr(indexOfColon + 1));

        //   if (argc < 3) {
        //     std::cerr << "Usage: " << host << " host port" << std::endl << std::endl;
        //   return -1;
        //}

        ConnectionHandler connectionHandler(host, port);
        User user;
        if (!connectionHandler.connect()) {
            cout << "Could not connect to server" << '\n';
            return 1;
        }

        user.setName(input.at(2));

        string output = "CONNECT\n";
        output = output + "accept-version:1.2\n";
        output = output + "host:stomp.cs.bgu.ac.il\n";
        output = output + "login:" + input.at(2) + "\n";
        output = output + "passcode:" + input.at(3) + "\n";
        output = output + "\n";
        //output=output+'\u0000';

        connectionHandler.sendFrameAscii(output, '\u0000');



        ServerCommunicate s(connectionHandler, user);
        thread thServer(s);

        while (!connectionHandler.getLockerLogin()){}

        connectionHandler.lockLogin();

        if(!connectionHandler.isLoggedOut()) {

            KeyBoardCommunicate kb(connectionHandler, user);
            thread thKeyBoard(kb);
            thKeyBoard.join();
        }
        thServer.join();

        user.clear();
        input.clear();




    return 0;
}
