
#ifndef CLIENT_USER_H
#define CLIENT_USER_H

#include <map>
#include <vector>

using namespace std;

class User {

public:
    User();
    //User(const User& other);
    //User& operator=(const User& other);
    virtual ~User();
    string getSubId(string& topic) const ;
    string getRecIdAndIncrement();
    string getName() const;
    string addIdSub(string& destination);
    void addBook(string& destination, string& book);
    void addBorrow(string& book, string& name);
    string returnBook(string& book);
    void addRec(int type, string& topic);
    int getTypeByRec(int recId);
    string getTopicByRec(int recId);
    void leaveTopic(string& topic);
    string myBooksOf(string& topic);
    bool hasBook(string& topic, string& book);
    void addToWishList(string& book);
    void deleteFromWishList(string& book);
    bool isAtMyWishList(string& book);
    void removeBookFromInventory(string& topic, string& book);
    void setName(string& name);
    bool borrowedBook(string& book);
    bool amISubscribeTo(string& topic);
    void clear();
private:
    string name;
    int subIdCounter;
    int recIdCounter;
    map<string,vector<string>> inventory;
    map<int,string> idSub;
    map<string,string> borrowMap;
    map<int,int> recToType;
    map<int,string> recToTopic;
    vector<string> wishList;

};

#endif //CLIENT_USER_H
