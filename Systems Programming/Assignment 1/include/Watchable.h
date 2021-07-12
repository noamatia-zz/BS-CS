#ifndef WATCHABLE_H_
#define WATCHABLE_H_

#include <string>
#include <vector>


class Session;

class Watchable{
public:
    //constructor:
    Watchable(long id, int length, const std::vector<std::string>& tags);
    //copy constructor:
    Watchable(const Watchable& other);
    //assignment operator:
    Watchable& operator=(const Watchable& other);
    //destructor:
    virtual ~Watchable();
    //public functions:
    virtual std::string toString() const = 0;
    virtual Watchable* getNextWatchable(Session&) const = 0;
    long getId() const;
    long getLength() const;
    std::vector<std::string> getTags() const;
    virtual void setId(long id);
    virtual Watchable* clone() const;
    virtual bool isEpisode()const;
private:
    //private fields:
    const long id;
    int length;
    std::vector<std::string> tags;
};

class Movie : public Watchable{
public:
    //constructor:
    Movie(long id, const std::string& name, int length, const std::vector<std::string>& tags);
    //copy constructor:
    Movie(const Movie& other);
    //assignment operator:
    Movie& operator=(const Movie& other);
    //destructor:
    virtual ~Movie();
    //public functions:
    virtual std::string toString() const;
    virtual Watchable* getNextWatchable(Session&) const;
    virtual Watchable* clone()const;
    virtual bool isEpisode()const;
private:
    //private fields:
    std::string name;
};

class Episode: public Watchable{
public:
    //constructor:
    Episode(long id, const std::string& seriesName, int length, int season, int episode ,const std::vector<std::string>& tags);
    //copy constructor:
    Episode(const Episode& other);
    //assignment operator:
    Episode& operator=(const Episode& other);
    //destructor:
    virtual ~Episode();
    //public functions:
    virtual std::string toString() const;
    virtual Watchable* getNextWatchable(Session&) const;
    void setNextEpisodeId(long id);
    virtual Watchable* clone()const;
    long getNextEpisodeId();
    virtual bool isEpisode()const;
private:
    //private fields:
    std::string seriesName;
    int season;
    int episode;
    long nextEpisodeId;
};

#endif
