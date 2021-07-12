#include "../include/Action.h"
#include "../include/Session.h"
#include "../include/Watchable.h"
#include "../include/User.h"
using namespace std;

//BaseAction:
//constructor:
BaseAction::BaseAction() : errorMsg("Error - <Action Failed>"), status(PENDING) {}
//copy constructor:
BaseAction::BaseAction(const BaseAction &other) : errorMsg(other.errorMsg), status(other.status) {}
//destructor:
BaseAction::~BaseAction() {}

//public functions:
ActionStatus BaseAction::getStatus() const { return status;}
void BaseAction::setStatus(ActionStatus s) {status=s;}
void BaseAction::setErrorMsg(string msg) {errorMsg=msg;}
BaseAction *BaseAction::clone() const {return nullptr;}

//protected functions:
void BaseAction::complete() {status=COMPLETED;}
void BaseAction::error(const std::string &errorMsg) {
    status=ERROR;
    cout<<errorMsg+"\n";
}
std::string BaseAction::getErrorMsg() const { return errorMsg;}




//CreateUser:
void CreateUser::act(Session &sess) {
    int nameCounter = sess.getUserMap().count(sess.getInput()[1]);
    if (nameCounter != 0) {
        error("Error - <Name is already exists>");
        return;
    }
    if ((sess.getInput()[2] != "len") & (sess.getInput()[2] != "rer") & (sess.getInput()[2] != "gen")) {
        error("Error - <Undefined Algorithm>");
        return;
    }
    if (sess.getInput()[2] == "len") {
        User *user = new LengthRecommenderUser(sess.getInput()[1]);
        sess.getUserMap().insert(make_pair(user->getName(), user));
    } else if (sess.getInput()[2] == "rer") {
        User *user = new RerunRecommenderUser(sess.getInput()[1]);
        sess.getUserMap().insert(make_pair(user->getName(), user));
    } else if (sess.getInput()[2] == "gen") {
        User *user = new GenreRecommenderUser(sess.getInput()[1]);
        sess.getUserMap().insert(make_pair(user->getName(), user));
    }
    complete();
}
std::string CreateUser::toString() const {
    if(getStatus()==ERROR) return "CreateUser "+getErrorMsg();
    return "CreateUser COMPLETED";
}
BaseAction* CreateUser:: clone()const{
    CreateUser* user=new CreateUser();
    user->setStatus(getStatus());
    user->setErrorMsg(getErrorMsg());

    return user;
}

//ChangeActiveUser:
void ChangeActiveUser::act(Session &sess) {
    int nameCounter = sess.getUserMap().count(sess.getInput()[1]);
    if(nameCounter!=1){
        error("Error - <Name does not exist>");
        return;
    }
    sess.setActiveUser(sess.getUserMap().at(sess.getInput()[1]));
    complete();
    }
std::string ChangeActiveUser::toString() const {
    if(getStatus()==ERROR) return "ChangeActiveUser "+getErrorMsg();
    return "ChangeActiveUser COMPLETED";
}
BaseAction* ChangeActiveUser:: clone()const{
    ChangeActiveUser* user=new ChangeActiveUser();
    user->setStatus(getStatus());
    user->setErrorMsg(getErrorMsg());

    return user;
}

//DeleteUser:
void DeleteUser::act(Session &sess) {
    int nameCounter = sess.getUserMap().count(sess.getInput()[1]);
    if(nameCounter!=1){
        error("Error - <User does not exist>");
        return;
    }
    delete sess.getUserMap().at(sess.getInput()[1]);
    sess.getUserMap().erase(sess.getInput()[1]);
    complete();
}
std::string DeleteUser::toString() const {
    if(getStatus()==ERROR) return "DeleteUser "+getErrorMsg();
    return "DeleteUser COMPLETED";
}
BaseAction* DeleteUser:: clone()const{
    DeleteUser* user=new DeleteUser();
    user->setStatus(getStatus());
    user->setErrorMsg(getErrorMsg());
    return user;
}

//DuplicateUser:
void DuplicateUser::act(Session &sess) {
    int nameCounter = sess.getUserMap().count(sess.getInput()[1]);
    if(nameCounter!=1){
        error("Error - <User does not exist>");
        return;
    }
    int newNameCounter = sess.getUserMap().count(sess.getInput()[2]);
    if (newNameCounter != 0) {
        error("Error - <Name is already exists>");
        return;
    }
    User* user=sess.getUserMap().at(sess.getInput()[1])->clone();
    user->setName(sess.getInput()[2]);
    sess.getUserMap().insert(make_pair(sess.getInput()[2], user));
    complete();
}
std::string DuplicateUser::toString() const {
    if(getStatus()==ERROR) return "DuplicateUser "+getErrorMsg();
    return "DuplicateUser COMPLETED";
}
BaseAction* DuplicateUser:: clone()const{
    DuplicateUser* user=new DuplicateUser();
    user->setStatus(getStatus());
    user->setErrorMsg(getErrorMsg());
    return user;
}

//PrintContentList:
void PrintContentList::act(Session &sess) {
    for (unsigned int i=0; i<sess.getContent().size(); i++){
        string name= sess.getContent()[i]->toString();
        string tags="[";
        for (unsigned int j = 0; j <sess.getContent()[i]->getTags().size()-1 ; j++) {
            tags=tags+sess.getContent()[i]->getTags()[j]+", ";
        }
        tags=tags+sess.getContent()[i]->getTags()[sess.getContent()[i]->getTags().size()-1]+"]";
        int length= sess.getContent()[i]->getLength();
        cout<<i+1;
        cout<<". "+name+" ";
        cout<<length;
        cout<<" minutes "+tags+"\n";
    }
    complete();
}
std::string PrintContentList::toString() const {
    if(getStatus()==ERROR) return "PrintContentList "+getErrorMsg();
    return "PrintContentList COMPLETED";
}
BaseAction* PrintContentList:: clone()const{
    PrintContentList* user=new PrintContentList();
    user->setStatus(getStatus());
    user->setErrorMsg(getErrorMsg());
    return user;
}

//PrintWatchHistory:
void PrintWatchHistory::act(Session &sess) {
    cout<<"Watch history for "+sess.getActiveUser()->getName()+"\n";
    for(unsigned int i=0;i<sess.getActiveUser()->get_history().size();i++){
        string name= sess.getActiveUser()->get_history()[i]->toString();
        string num=to_string(i+1);
        cout<<num+". "+name+"\n";
    }
    complete();
}
std::string PrintWatchHistory::toString() const {
    if(getStatus()==ERROR) return "PrintWatchHistory "+getErrorMsg();
    return "PrintWatchHistory COMPLETED";
}
BaseAction* PrintWatchHistory:: clone()const{
    PrintWatchHistory* user=new PrintWatchHistory();
    user->setStatus(getStatus());
    user->setErrorMsg(getErrorMsg());
    return user;
}

//Watch:
void Watch::act(Session &sess) {
    unsigned int id=std::stoi(sess.getInput()[1]);
    if((id > sess.getContent().size())|(id<1)) {
        error("Error - <Id does not exist>");
        return ;
    }

    sess.getActiveUser()->set_history(sess.getContent()[id-1]);

    cout<<"Watching "+(sess.getContent()[id-1]->toString())+"\n";

    complete();
}
std::string Watch::toString() const {
    if(getStatus()==ERROR) return "Watch "+getErrorMsg();
    return "Watch COMPLETED";
}
BaseAction* Watch:: clone()const{
    Watch* user=new Watch();
    user->setStatus(getStatus());
    user->setErrorMsg(getErrorMsg());
    return user;
}

//PrintActionsLog:
void PrintActionsLog::act(Session &sess) {
    for(int i=sess.getActionsLog().size()-1; i>=0; i--){
       cout<<sess.getActionsLog()[i]->toString()+"\n";
       complete();
    }
}
std::string PrintActionsLog::toString() const {
    if(getStatus()==ERROR) return "PrintActionsLog "+getErrorMsg();
    return "PrintActionsLog COMPLETED";
}
BaseAction* PrintActionsLog:: clone()const{
    PrintActionsLog* user=new PrintActionsLog();
    user->setStatus(getStatus());
    user->setErrorMsg(getErrorMsg());
    return user;
}

//Exit:
void Exit::act(Session &sess) {
    complete();
    }

std::string Exit::toString() const {
    if(getStatus()==ERROR) return "Exit "+getErrorMsg();
    return "Exit COMPLETED";
}
BaseAction* Exit:: clone()const{
    Exit* user=new Exit();
    user->setStatus(getStatus());
    user->setErrorMsg(getErrorMsg());
    return user;
}