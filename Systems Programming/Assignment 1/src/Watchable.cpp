#include "../include/Watchable.h"
#include "../include/Session.h"
#include "../include/User.h"
using namespace std;

//Watchable:
//constructor:
Watchable :: Watchable(long id, int length, const std::vector<std::string> &tags) : id(id), length(length), tags(tags) {}
//copy constructor:
Watchable :: Watchable(const Watchable &other) : id(other.id), length(other.length), tags(other.tags) {}
//assignment operator:
Watchable& Watchable ::operator=(const Watchable& other) {
    if (this == &other){
        return *this;
    }
    setId(other.id);
    length=other.length;
    tags=other.tags;
    return *this;
}
//destructor:
Watchable ::~Watchable() {}
//public functions:
long Watchable ::getId() const { return id;}
void Watchable ::setId(long id) {id=id;}
long Watchable ::getLength() const { return length;}
std::vector<std::string> Watchable ::getTags() const { return tags;}
Watchable *Watchable::clone() const {return nullptr;}
bool Watchable::isEpisode() const {return false;}


//Movie:
//constructor:
Movie :: Movie(long id, const std::string &name, int length, const std::vector<std::string> &tags) : Watchable(id, length, tags), name(name) {}
//copy constructor:
Movie :: Movie(const Movie &other) : Watchable(other), name(other.name) {}
//assignment operator:
Movie& Movie ::operator=(const Movie &other) {
    if (this == &other){
        return *this;
    }
operator=(other);
    name=other.name;
    return *this;
}
//destructor:
Movie ::~Movie() {}
//public functions:
string Movie :: toString() const { return name;}
Watchable* Movie :: getNextWatchable(Session & s) const {
    unsigned long id=getId();
    if (s.getContent().size()==id){return s.getContent()[0];}
    else{ return s.getContent()[getId()];}
}
Watchable* Movie:: clone()const{
    Movie* movie=new Movie(getId(), this->name, getLength(), getTags());
    return movie;
}
bool Movie::isEpisode() const { return false;}

//Episode:
//constructor:
Episode :: Episode(long id, const std::string &seriesName, int length, int season, int episode, const std::vector<std::string> &tags) :
     Watchable(id, length, tags), seriesName(seriesName), season(season), episode(episode), nextEpisodeId(-1){}
//copy constructor:
Episode :: Episode(const Episode &other) : Watchable(other), seriesName(other.seriesName), season(other.season), episode(other.episode), nextEpisodeId(other.nextEpisodeId) {}
//assignment operator:
Episode& Episode ::operator=(const Episode &other) {
    if (this == &other){
        return *this;
    }
    operator=(other);
    seriesName=other.seriesName;
    season=other.season;
    episode=other.episode;
    nextEpisodeId=other.nextEpisodeId;
    return *this;
}
//destructor:
Episode ::~Episode() {}
//public functions:
string Episode ::toString() const { return seriesName+" S"+to_string(season)+" E"+to_string(episode);}
Watchable* Episode :: getNextWatchable(Session & s) const {
    unsigned long id = getId();
    if (s.getContent().size()==id)return s.getContent()[1];
    else return s.getContent()[getId()+1];
}
void Episode ::setNextEpisodeId(long id) {nextEpisodeId=id;}
Watchable* Episode:: clone()const{
    Episode* episode=new Episode(getId(), this->seriesName, getLength(), this->season, this->episode,getTags());
    episode->setNextEpisodeId(nextEpisodeId);
    return episode;
}
long Episode::getNextEpisodeId() { return nextEpisodeId;}
bool Episode::isEpisode() const { return true;}



