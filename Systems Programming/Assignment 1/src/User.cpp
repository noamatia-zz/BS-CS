#include <vector>
#include <algorithm>
#include "../include/Session.h"
#include "../include/Watchable.h"
#include "../include/User.h"
using namespace std;

//User:
//constructor:
User::User(const std::string &name) :history(), name(name) {}
//1.copy constructor:
User::User(const User &other) : history(), name(other.name) {
    for(unsigned int i=0; i<other.history.size(); i++)
        history.push_back(other.history[i]->clone());
}
//2.assignment operator:
User& User::operator=(const User& other){

    clear();

    for(unsigned int i=0; i<other.history.size(); i++)
        history.push_back(other.history[i]->clone());

    return *this;
}
//3.destructor:
User::~User() {clear();}
//4.move constructor:
User::User(User &&other) : history(), name(other.name) {

    for(unsigned int i=0; i<other.history.size(); i++)
        history.push_back(other.history[i]->clone());

    other.clear();
}
//5.move assignment operator:
User& User::operator=(User &&other) {
    if(this != &other) {
        clear();
        for(unsigned int i=0; i<other.history.size(); i++)
            history.push_back(other.history[i]->clone());

        other.clear();
    }
    return *this;
}

//public functions:
std::string User::getName() const { return name;}
std::vector<Watchable*> User::get_history() const { return history;}
void User::clear() {}
User *User::clone() const {return nullptr;}
void User::set_history(Watchable* w) {history.push_back(w);}
void User::setName(std::string &n) {name=n;}
void User::clearHistory() {history.clear();}

//LengthRecommenderUser:
//constructor:
LengthRecommenderUser::LengthRecommenderUser(const std::string &name) : User(name) {}
//1.copy constructor
LengthRecommenderUser::LengthRecommenderUser(const LengthRecommenderUser& other) : User(other){}
//2.assignment operator:
LengthRecommenderUser& LengthRecommenderUser::operator=(const LengthRecommenderUser& other){

    clear();

    for(unsigned int i=0; i<other.history.size(); i++)
        history.push_back(other.history[i]->clone());

    return *this;
}
//3.destructor:
LengthRecommenderUser::~LengthRecommenderUser() {clear();}
//4.move constructor:
LengthRecommenderUser::LengthRecommenderUser(LengthRecommenderUser &&other) : User(other) {}
//5.move assignment operator:
LengthRecommenderUser& LengthRecommenderUser::operator=(LengthRecommenderUser &&other) {
    if(this != &other) {
        clear();
        for(unsigned int i=0; i<other.history.size(); i++)
            history.push_back(other.history[i]->clone());

        other.clear();
    }
    return *this;
}

//public:
Watchable* LengthRecommenderUser::getRecommendation(Session &s) {
    if (history.empty()) return nullptr;
    if ((history[history.size()-1])->isEpisode() && dynamic_cast<Episode *>(history[history.size() - 1])->getNextEpisodeId() != -1) {

            return s.getContent()[dynamic_cast<Episode *>(history[history.size() - 1])->getNextEpisodeId()-1];

    }
    else {
            double average = 0;
            for (unsigned int i = 0; i < history.size(); i++)
                average = average + history[i]->getLength();

            average = average / history.size();

            vector<pair<double, int> > v;

            for (unsigned int i = 0; i < s.getContent().size(); i++) {
                double differ = average - s.getContent()[i]->getLength();
                if (differ < 0)differ = differ * (-1);
                v.push_back(make_pair(differ, i + 1));
            }

            sort(v.begin(), v.end());

            for (unsigned int i = 0; i < v.size(); i++) {
                bool hasWatched = false;
                for (unsigned int j = 0; (!hasWatched) & (j < history.size()); j++) {
                    if (v[i].second == history[j]->getId()) hasWatched = true;
                }
                if (!hasWatched) return s.getContent()[v[i].second - 1];
            }
            return nullptr;
        }
    }
User* LengthRecommenderUser:: clone()const {
    LengthRecommenderUser* user = new LengthRecommenderUser(getName());
    for(unsigned int i=0;i<history.size();i++)
        user->history.push_back(history[i]);

    return user;
}



//RerunRecommenderUser
//constructor
RerunRecommenderUser::RerunRecommenderUser(const std::string &name) : User(name), index(0) {}
//1.copy constructor
RerunRecommenderUser::RerunRecommenderUser(const RerunRecommenderUser& other) : User(other),index(other.index){}
//2.assignment operator:
RerunRecommenderUser& RerunRecommenderUser::operator=(const RerunRecommenderUser& other){

    clear();

    for(unsigned int i=0; i<other.history.size(); i++)
        history.push_back(other.history[i]->clone());

    index=other.index;

    return *this;
}
//3.destructor:
RerunRecommenderUser::~RerunRecommenderUser() {clear();}
//4.move constructor:
RerunRecommenderUser::RerunRecommenderUser(RerunRecommenderUser &&other) : User(other), index() {index=other.index;}
//5.move assignment operator:
RerunRecommenderUser& RerunRecommenderUser::operator=(RerunRecommenderUser &&other) {
    if(this != &other) {
        clear();
        for(unsigned int i=0; i<other.history.size(); i++)
            history.push_back(other.history[i]->clone());

        index=other.index;
        other.clear();
    }
    return *this;
}

//public functions:
Watchable* RerunRecommenderUser::getRecommendation(Session &s) {

    if(history.empty())return nullptr;
    if ((history[history.size()-1])->isEpisode() && dynamic_cast<Episode *>(history[history.size() - 1])->getNextEpisodeId() != -1) {

        return s.getContent()[dynamic_cast<Episode *>(history[history.size() - 1])->getNextEpisodeId()-1];

    }
     else {
index++;
        return history[(index-1) % (history.size())];
    }
}
User* RerunRecommenderUser:: clone()const {
    RerunRecommenderUser* user = new RerunRecommenderUser(getName());

    user->index=index;

    for(unsigned int i=0;i<history.size();i++)
        user->history.push_back(history[i]);

    return user;
}




//GenreRecommenderUser:
//constructor
GenreRecommenderUser::GenreRecommenderUser(const std::string &name) : User(name) {}
//1.copy constructor
GenreRecommenderUser::GenreRecommenderUser(const GenreRecommenderUser& other) : User(other){}
//2.assignment operator:
GenreRecommenderUser& GenreRecommenderUser::operator=(const GenreRecommenderUser& other){

    clear();

    for(unsigned int i=0; i<other.history.size(); i++)
        history.push_back(other.history[i]->clone());

    return *this;
}
//3.destructor:
GenreRecommenderUser::~GenreRecommenderUser() {clear();}
//4.move constructor:
GenreRecommenderUser::GenreRecommenderUser(GenreRecommenderUser &&other) : User(other) {}
//5.move assignment operator:
GenreRecommenderUser& GenreRecommenderUser::operator=(GenreRecommenderUser &&other) {
    if(this != &other) {
        clear();
        for(unsigned int i=0; i<other.history.size(); i++)
            history.push_back(other.history[i]->clone());

        other.clear();
    }
    return *this;
}

//public functions:
Watchable* GenreRecommenderUser::getRecommendation(Session &s) {
    if (history.empty())return nullptr;
    if ((history[history.size()-1])->isEpisode() && dynamic_cast<Episode *>(history[history.size() - 1])->getNextEpisodeId() != -1) {

        return s.getContent()[dynamic_cast<Episode *>(history[history.size() - 1])->getNextEpisodeId()-1];

    } else {
        vector<pair<int, string> > v;
        int vNumOfTags = 0;

        for (unsigned int i = 0; i < history.size(); i++) {
            for (unsigned int j = 0; j < history[i]->getTags().size(); j++) {
                string tag = history[i]->getTags()[j];
                bool found = false;
                for (unsigned int k = 0; (k < v.size()) & (!found); k++) {
                    if (v[k].second == tag) {
                        v[k].first++;
                        found = true;
                    }
                }
                if (!found) {
                    v.push_back(make_pair(1, tag));
                    vNumOfTags++;
                }
            }
        }
        while (vNumOfTags != 0) {

            sort(v.rbegin(), v.rend());

            int index = 0;
            int maxTemp = v[0].first;
            string maxTempTag = v[0].second;

            for (unsigned int i = 1; i < v.size(); ++i) {
                if ((v[i].first == maxTemp) & (v[i].second < maxTempTag)) {
                    maxTempTag = v[i].second;
                    index = i;
                }
            }
            bool hasWatchable = false;
            for (unsigned int i = 0; i < s.getContent().size(); i++) {
                for (unsigned int j = 0; j < s.getContent()[i]->getTags().size(); j++) {
                    if (s.getContent()[i]->getTags()[j] == maxTempTag) {
                        for (unsigned int k = 0; (k < history.size()) & (!hasWatchable); k++) {
                            if (history[k]->getId() == s.getContent()[i]->getId()) hasWatchable = true;
                        }
                        if (!hasWatchable)return s.getContent()[i];
                        hasWatchable = false;
                    }
                }
            }
            v[index].first = 0;
            vNumOfTags--;
        }
        return nullptr;
    }
}
User* GenreRecommenderUser:: clone()const {
    GenreRecommenderUser* user = new GenreRecommenderUser(getName());
    for(unsigned int i=0;i<history.size();i++)
        user->history.push_back(history[i]);

    return user;
}
