#ifndef USER_H_
#define USER_H_

#include <vector>
#include <string>
#include <unordered_set>
#include <unordered_map>
class Watchable;
class Session;

class User{
public:
    //constructor:
    User(const std::string& name);
    //1.copy constructor:
    User(const User& other);
    //2.assignment operator:
    User& operator=(const User& other);
    //3.destructor:
    virtual ~User();
    //4.move constructor:
    User(User&& other);
    //5.move assignment operator:
    User& operator=(User&& other);

    //public functions:
    virtual Watchable* getRecommendation(Session& s) = 0;
    std::string getName() const;
    std::vector<Watchable*> get_history() const;
    void set_history(Watchable*);
    virtual User* clone() const;
    void clear();
    void setName(std::string& n);
    void clearHistory();
protected:
    std::vector<Watchable*> history;
private:
    std::string name;
};

class LengthRecommenderUser : public User {
public:
    //constructor:
    LengthRecommenderUser(const std::string& name);
    //1.copy constructor:
    LengthRecommenderUser(const LengthRecommenderUser& other);
    //2.assignment operator:
    LengthRecommenderUser& operator=(const LengthRecommenderUser& other);
    //3.destructor:
    virtual ~LengthRecommenderUser();
    //4.move constructor:
    LengthRecommenderUser(LengthRecommenderUser&& other);
    //5.move assignment operator:
    LengthRecommenderUser& operator=(LengthRecommenderUser&& other);

    //public functions:
    virtual Watchable* getRecommendation(Session& s);
    virtual User* clone() const;

private:
};

class RerunRecommenderUser : public User {
public:
    //constructor:
    RerunRecommenderUser(const std::string& name);
    //1.copy constructor:
    RerunRecommenderUser(const RerunRecommenderUser& other);
    //2.assignment operator:
    RerunRecommenderUser& operator=(const RerunRecommenderUser& other);
    //3.destructor:
    virtual ~RerunRecommenderUser();
    //4.move constructor:
    RerunRecommenderUser(RerunRecommenderUser&& other);
    //5.move assignment operator:
    RerunRecommenderUser& operator=(RerunRecommenderUser&& other);

    //public functions:
    virtual Watchable* getRecommendation(Session& s);
    virtual User* clone() const;

private:
    int index;
};

class GenreRecommenderUser : public User {
public:
    //constructor:
    GenreRecommenderUser(const std::string& name);
    //1.copy constructor:
    GenreRecommenderUser(const GenreRecommenderUser& other);
    //2.assignment operator:
    GenreRecommenderUser& operator=(const GenreRecommenderUser& other);
    //3.destructor:
    virtual ~GenreRecommenderUser();
    //4.move constructor:
    GenreRecommenderUser(GenreRecommenderUser&& other);
    //5.move assignment operator:
    GenreRecommenderUser& operator=(GenreRecommenderUser&& other);

    //public functions:
    virtual Watchable* getRecommendation(Session& s);
    virtual User* clone() const;

private:

};

#endif
