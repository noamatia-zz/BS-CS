#include <map>
#include <vector>
#include "../include/User.h"

using namespace std;

User::User() : name(), subIdCounter(0), recIdCounter(0), inventory(), idSub(), borrowMap(), recToType(),recToTopic(), wishList(){};

User::~User() {clear();}

string User::getSubId(string &topic) const {
    for (auto it = idSub.begin(); it!=idSub.end(); ++it) {
        if(it->second == topic)
            return to_string(it->first);
    }
    return "a";
}
string User::getRecIdAndIncrement(){
    int output=recIdCounter;
    recIdCounter++;
    return to_string(output);
}

string User::getName() const {
    return name;
}

string User::addIdSub(string &destination) {
    idSub.insert(pair<int, string>(subIdCounter, destination));
    vector<string> v;
    inventory.insert(pair<string, vector<string>>(destination, v));
    subIdCounter++;
    return to_string(subIdCounter-1);
}

void User::addBook(string &destination, string &book) {
    if (inventory.count(destination)==0){
        vector<string> v;
        inventory.insert(pair<string, vector<string>>(destination, v));
    }
    inventory.at(destination).push_back(book);
}

void User::addBorrow(string &book, string &name) {
    borrowMap.insert(pair<string,string>(book, name));
}


string User::returnBook(string &book) {
    string output = borrowMap.at(book);
    borrowMap.erase(book);
    return output;
}

void User::addRec(int type, string &topic) {
  recToType.insert(pair<int,int>(recIdCounter, type));
  recToTopic.insert(pair<int,string>(recIdCounter, topic));
}

string User::getTopicByRec(int recId) {
    return recToTopic.at(recId);
}

int User::getTypeByRec(int recId) {
    return recToType.at(recId);
}

void User::leaveTopic(string &topic) {
    if(inventory.count(topic)>0) {
        inventory.erase(topic);
        for (auto it = idSub.begin(); it != idSub.end(); ++it) {
            if (it->second == topic)
                idSub.erase(it->first);
        }
    }
}

string User::myBooksOf(string &topic) {
    string output=name+":";
    for (unsigned int i = 0; i <inventory.at(topic).size() ; ++i) {
        output=output+inventory.at(topic).at(i)+",";
    }
    output=output.substr(0,output.length()-1);
    return output;
}

bool User::hasBook(string &topic, string &book) {
    bool output=false;
    if(inventory.count(topic)!=0){
        for(unsigned int i=0; (i<inventory.at(topic).size()) & (!output); i++ )
            output = inventory.at(topic).at(i)==book;
    }
    return output;
}

void User::addToWishList(string &book) {wishList.push_back(book);}

void User::deleteFromWishList(string &book) {
    for(auto it = wishList.begin(); it!=wishList.end(); it++)
        if(book == *it){
            wishList.erase(it);
            break;
        }

}

bool User::isAtMyWishList(string &book) {
    for(auto it = wishList.begin(); it!=wishList.end(); it++)
        if(*it == book)return true;

    return false;
}

void User::removeBookFromInventory(string &topic, string &book) {
    for( auto it = inventory.at(topic).begin(); it!= inventory.at(topic).end(); it++){
        if(*it==book) {
            inventory.at(topic).erase(it);
            break;
        }
    }
}

void User::setName(string &name) {this->name=name;}

bool User::borrowedBook(string &book) {
    return (borrowMap.count(book)>0);
}

bool User::amISubscribeTo(string &topic) {
    if (inventory.count(topic)>=1)
        return true;
    else{
        return false;
    }
}

void User::clear() {



    inventory.clear();
    idSub.clear();
    borrowMap.clear();
    recToTopic.clear();
    recToType.clear();
    wishList.clear();
}