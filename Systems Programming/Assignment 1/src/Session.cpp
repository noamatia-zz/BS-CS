#include <iostream>
#include <fstream>
#include <vector>
#include <unordered_map>
#include<bits/stdc++.h>
#include "../include/Session.h"
#include "../include/Watchable.h"
#include "../include/User.h"
#include "../include/Action.h"
#include "../include/json.hpp"
using namespace std;
using json = nlohmann::json;

//constructor:
Session::Session(const std::string &configFilePath) : content(), actionsLog(std::vector<BaseAction*>()), userMap(std::unordered_map<std::string,User*>()), activeUser(nullptr), input(){
    ifstream i(configFilePath);
    json j;
    i>>j;
    long id=1;
    for(auto o = j["movies"].begin(); o != j["movies"].end(); o++){
        json movie = o.value();
        int length = movie["length"];
        string name = movie["name"];
        vector<string> tags = movie ["tags"];
        Watchable* watch = new Movie(id, name, length, tags);
        id++;
        content.push_back(watch);
    }
    for(auto o = j["tv_series"].begin(); o != j["tv_series"].end(); o++){

        json series = o.value();
        vector<string>tags = series["tags"];
        string name = series["name"];
        int length = series["episode_length"];
        vector<int> seasons=series["seasons"];
        for(unsigned int i=0; i<seasons.size(); i++){
            int numOfEpisodes=seasons.at(i);
            for(int j=0; j<numOfEpisodes; j++){
                Episode* episode = new Episode(id, name, length, i+1, j+1, tags);
                id++;
                episode->setNextEpisodeId(id);
                content.push_back(episode);
            }

        }
        static_cast<Episode*>(content[id-2])->setNextEpisodeId(-1);
    }
}
//1.copy constructor
Session::Session(const Session& other) : content(), actionsLog(), userMap(), activeUser(), input(other.input) {

    vector<int>v;

    for (unsigned int i = 0; i < other.content.size(); i++) {
        content.push_back(other.content[i]->clone());
    }
    for (unsigned int i = 0; i < other.actionsLog.size(); i++) {
        actionsLog.push_back(other.actionsLog[i]->clone());
    }
    for (auto i = other.userMap.begin(); i != other.userMap.end(); i++) {
        userMap.insert(make_pair(((*i).first), (*i).second->clone()));
    }


    for (auto j = this->userMap.begin(); j != this->userMap.end(); j++) {

        for (unsigned int i = 0; i < (*j).second->get_history().size(); ++i) {
                v.push_back((*j).second->get_history()[i]->getId());
            }

            (*j).second->clearHistory();
        for(unsigned int k=0;k<v.size();k++)
                (*j).second->set_history(this->content[v[k]-1]);

            v.clear();
        }


        this->activeUser = userMap.at(other.getActiveUser()->getName());

}
//2.assignment operator:
Session& Session::operator = (const Session &other) {
    clear();

    vector<int>v;

    for (unsigned int i = 0; i < other.content.size(); i++)
        content.push_back(other.content[i]->clone());

    for (unsigned int i = 0; i < other.actionsLog.size(); i++)
        actionsLog.push_back(other.actionsLog[i]->clone());

    for (auto i = other.userMap.begin(); i != other.userMap.end(); i++)
        userMap.insert(make_pair(((*i).first), (*i).second->clone()));


    for (auto j = this->userMap.begin(); j != this->userMap.end(); j++) {

        for (unsigned int i = 0; i < (*j).second->get_history().size(); ++i) {
            v.push_back((*j).second->get_history()[i]->getId());
        }

        (*j).second->clearHistory();
        for(unsigned int k=0;k<v.size();k++)
            (*j).second->set_history(this->content[v[k]-1]);

        v.clear();
    }


    this->activeUser = userMap.at(other.getActiveUser()->getName());

    input=other.input;

    return *this;
}
//3.destructor:
Session::~Session() {clear();}
//4.move constructor:
Session::Session(Session &&other) : content(), actionsLog(), userMap(), activeUser(), input() {

    input=other.input;

    vector<int>v;

    for (unsigned int i = 0; i < other.content.size(); i++)
        content.push_back(other.content[i]->clone());

    for (unsigned int i = 0; i < other.actionsLog.size(); i++)
        actionsLog.push_back(other.actionsLog[i]->clone());

    for (auto i = other.userMap.begin(); i != other.userMap.end(); i++)
        userMap.insert(make_pair(((*i).first), (*i).second->clone()));



    for (auto j = this->userMap.begin(); j != this->userMap.end(); j++) {

        for (unsigned int i = 0; i < (*j).second->get_history().size(); ++i) {
            v.push_back((*j).second->get_history()[i]->getId());
        }

        (*j).second->clearHistory();
        for(unsigned int k=0;k<v.size();k++)
            (*j).second->set_history(this->content[v[k]-1]);

        v.clear();
    }


    this->activeUser = userMap.at(other.getActiveUser()->getName());

    other.clear();

}
//5.move assignment operator:
Session& Session::operator=(Session &&other) {
    if(this != &other) {
        clear();
        vector<int>v;

        for (unsigned int i = 0; i < other.content.size(); i++)
            content.push_back(other.content[i]->clone());

        for (unsigned int i = 0; i < other.actionsLog.size(); i++)
            actionsLog.push_back(other.actionsLog[i]->clone());

        for (auto i = other.userMap.begin(); i != other.userMap.end(); i++)
            userMap.insert(make_pair(((*i).first), (*i).second->clone()));



        for (auto j = this->userMap.begin(); j != this->userMap.end(); j++) {

            for (unsigned int i = 0; i < (*j).second->get_history().size(); ++i) {
                v.push_back((*j).second->get_history()[i]->getId());
            }

            (*j).second->clearHistory();
            for(unsigned int k=0;k<v.size();k++)
                (*j).second->set_history(this->content[v[k]-1]);

            v.clear();
        }


        this->activeUser = userMap.at(other.getActiveUser()->getName());

        input=other.input;

        other.clear();
    }
    return *this;
}

//public functions:
void Session :: start() {
    cout << "SPLFLIX is now on!\n";
    if (userMap.empty()) {
        LengthRecommenderUser *user = new LengthRecommenderUser("default");
        userMap.insert({"default", user});
        activeUser = user;
    }
    string s,t;
    getline(cin, s);
    stringstream X(s);
    while(getline(X, t, ' '))input.push_back(t);

    while ((getInput()[0] != "exit") | (getInput().size() != 1)) {
        if ((getInput()[0] == "createuser") & (getInput().size() == 3)) {
            CreateUser *action = new CreateUser();
            action->act(*this);
            actionsLog.push_back(action);
        } else if ((getInput()[0] == "changeuser") & (getInput().size() == 2)) {
            ChangeActiveUser *action = new ChangeActiveUser();
            action->act(*this);
            actionsLog.push_back(action);
        } else if ((getInput()[0] == "deleteuser") & (getInput().size() == 2)) {
            DeleteUser *action = new DeleteUser();
            action->act(*this);
            actionsLog.push_back(action);
        } else if ((getInput()[0] == "dupuser") & (getInput().size() == 3)) {
            DuplicateUser *action = new DuplicateUser();
            action->act(*this);
            actionsLog.push_back(action);
        } else if ((getInput()[0] == "content") & (getInput().size() == 1)) {
            PrintContentList *action = new PrintContentList;
            action->act(*this);
            actionsLog.push_back(action);
        } else if ((getInput()[0] == "watchhist") & (getInput().size() == 1)) {
            PrintWatchHistory *action = new PrintWatchHistory();
            action->act(*this);
            actionsLog.push_back(action);
        } else if ((getInput()[0] == "watch") & (getInput().size() == 2) &&
                (std::find_if(input[1].begin(), input[1].end(), [](char c) { return !std::isdigit(c); }) ==
                   input[1].end())) {
            string yORn = "y";
            while (yORn == "y") {
                Watch *action = new Watch();
                action->act(*this);
                actionsLog.push_back(action);
                if (action->getStatus() == COMPLETED) {
                 Watchable *toWatch = getActiveUser()->getRecommendation(*this);

                    if (toWatch != nullptr) {
                        cout << "We recommend watching " + toWatch->toString() + ", continue watching? [y/n]\n";
                        getline(cin, yORn);
                        while ((yORn != "n") & (yORn != "y")) {
                            getline(cin, yORn);
                        }
                        input[1] = to_string(toWatch->getId());
                    }else yORn = "no";
                } else yORn = "no";
            }
        }

        else if ((getInput()[0] == "log") & (getInput().size() == 1)) {
            PrintActionsLog *action = new PrintActionsLog();
            action->act(*this);
            actionsLog.push_back(action);
        } else if((getInput()[0] == "exit") & (getInput().size() == 1)){
            Exit *action = new Exit();
            action->act(*this);
            actionsLog.push_back(action);

        }


        input.clear();
        string s,t;
        getline(cin, s);
        stringstream X(s);
        while(getline(X, t, ' '))input.push_back(t);

    }
    input.clear();
}
const vector<Watchable *>& Session::getContent() const { return content;}
void Session::clear() {
    for(unsigned int i=0; i<content.size(); i++)
        delete content[i];

    for(unsigned int i=0; i<actionsLog.size(); i++)
        delete actionsLog[i];

    for(auto i=userMap.begin();i!=userMap.end(); i++)
        delete (i->second);

    content.clear();
    actionsLog.clear();
    userMap.clear();
    //delete activeUser;

}

std::vector<std::string>& Session::getInput() { return input;}
std::unordered_map<std::string,User*>& Session::getUserMap() { return userMap;}
void Session::setActiveUser(User* user) {activeUser=user;}
User* Session::getActiveUser () const { return activeUser;}
std::vector<BaseAction*> Session::getActionsLog() { return actionsLog;}