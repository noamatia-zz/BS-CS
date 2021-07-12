#ifndef SESSION_H_
#define SESSION_H_

#include <vector>
#include <unordered_map>
#include <string>
#include "Action.h"

class User;
class Watchable;

class Session{
public:

    //constructor:
    Session(const std::string &configFilePath);
    //1.copy constructor
    Session(const Session& other);
    //2.assignment operator:
    Session& operator=(const Session& other);
    //3.destructor:
    ~Session();
    //4.move constructor:
    Session(Session&& other);
    //5.move assignment operator:
    Session& operator=(Session&& other);
    //public functions:
    void start();
    const std::vector<Watchable *>& getContent() const;
    void clear();
    std::vector<std::string>& getInput();
    std::unordered_map<std::string,User*>& getUserMap();
    void setActiveUser(User* user);
    User* getActiveUser() const;
    std::vector<BaseAction*> getActionsLog();
private:
    std::vector<Watchable*> content;
    std::vector<BaseAction*> actionsLog;
    std::unordered_map<std::string,User*> userMap;
    User* activeUser;
    std::vector<std::string> input;
};
#endif
