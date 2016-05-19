#include "lua_cocos2dx_custom_auto.hpp"
#include "custom/FightManager.hpp"
#include "custom/FightNode.hpp"
#include "tolua_fix.h"
#include "LuaBasicConversions.h"


int lua_cocos2dx_custom_FightResult_isDead(lua_State* tolua_S)
{
    int argc = 0;
    sgzj::FightResult* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"sgzj.FightResult",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (sgzj::FightResult*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_custom_FightResult_isDead'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_FightResult_isDead'", nullptr);
            return 0;
        }
        bool ret = cobj->isDead();
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "sgzj.FightResult:isDead",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_FightResult_isDead'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_custom_FightResult_nodeId(lua_State* tolua_S)
{
    int argc = 0;
    sgzj::FightResult* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"sgzj.FightResult",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (sgzj::FightResult*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_custom_FightResult_nodeId'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_FightResult_nodeId'", nullptr);
            return 0;
        }
        int ret = cobj->nodeId();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "sgzj.FightResult:nodeId",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_FightResult_nodeId'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_custom_FightResult_damage(lua_State* tolua_S)
{
    int argc = 0;
    sgzj::FightResult* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"sgzj.FightResult",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (sgzj::FightResult*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_custom_FightResult_damage'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_FightResult_damage'", nullptr);
            return 0;
        }
        double ret = cobj->damage();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "sgzj.FightResult:damage",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_FightResult_damage'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_custom_FightResult_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"sgzj.FightResult",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 4)
    {
        sgzj::FightNode* arg0;
        sgzj::FightNode* arg1;
        int arg2;
        double arg3;
        ok &= luaval_to_object<sgzj::FightNode>(tolua_S, 2, "sgzj.FightNode",&arg0, "sgzj.FightResult:create");
        ok &= luaval_to_object<sgzj::FightNode>(tolua_S, 3, "sgzj.FightNode",&arg1, "sgzj.FightResult:create");
        ok &= luaval_to_int32(tolua_S, 4,(int *)&arg2, "sgzj.FightResult:create");
        ok &= luaval_to_number(tolua_S, 5,&arg3, "sgzj.FightResult:create");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_FightResult_create'", nullptr);
            return 0;
        }
        sgzj::FightResult* ret = sgzj::FightResult::create(arg0, arg1, arg2, arg3);
        object_to_luaval<sgzj::FightResult>(tolua_S, "sgzj.FightResult",(sgzj::FightResult*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "sgzj.FightResult:create",argc, 4);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_FightResult_create'.",&tolua_err);
#endif
    return 0;
}
static int lua_cocos2dx_custom_FightResult_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (FightResult)");
    return 0;
}

int lua_register_cocos2dx_custom_FightResult(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"sgzj.FightResult");
    tolua_cclass(tolua_S,"FightResult","sgzj.FightResult","cc.Ref",nullptr);

    tolua_beginmodule(tolua_S,"FightResult");
        tolua_function(tolua_S,"isDead",lua_cocos2dx_custom_FightResult_isDead);
        tolua_function(tolua_S,"nodeId",lua_cocos2dx_custom_FightResult_nodeId);
        tolua_function(tolua_S,"damage",lua_cocos2dx_custom_FightResult_damage);
        tolua_function(tolua_S,"create", lua_cocos2dx_custom_FightResult_create);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(sgzj::FightResult).name();
    g_luaType[typeName] = "sgzj.FightResult";
    g_typeCast["FightResult"] = "sgzj.FightResult";
    return 1;
}

int lua_cocos2dx_custom_FightNode_AddFightResult(lua_State* tolua_S)
{
    int argc = 0;
    sgzj::FightNode* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"sgzj.FightNode",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (sgzj::FightNode*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_custom_FightNode_AddFightResult'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        sgzj::FightResult* arg0;

        ok &= luaval_to_object<sgzj::FightResult>(tolua_S, 2, "sgzj.FightResult",&arg0, "sgzj.FightNode:AddFightResult");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_FightNode_AddFightResult'", nullptr);
            return 0;
        }
        cobj->AddFightResult(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "sgzj.FightNode:AddFightResult",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_FightNode_AddFightResult'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_custom_FightNode_setDamage(lua_State* tolua_S)
{
    int argc = 0;
    sgzj::FightNode* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"sgzj.FightNode",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (sgzj::FightNode*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_custom_FightNode_setDamage'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        double arg0;

        ok &= luaval_to_number(tolua_S, 2,&arg0, "sgzj.FightNode:setDamage");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_FightNode_setDamage'", nullptr);
            return 0;
        }
        cobj->setDamage(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "sgzj.FightNode:setDamage",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_FightNode_setDamage'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_custom_FightNode_mergeDamage(lua_State* tolua_S)
{
    int argc = 0;
    sgzj::FightNode* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"sgzj.FightNode",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (sgzj::FightNode*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_custom_FightNode_mergeDamage'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_FightNode_mergeDamage'", nullptr);
            return 0;
        }
        cobj->mergeDamage();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "sgzj.FightNode:mergeDamage",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_FightNode_mergeDamage'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_custom_FightNode_getResultList(lua_State* tolua_S)
{
    int argc = 0;
    sgzj::FightNode* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"sgzj.FightNode",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (sgzj::FightNode*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_custom_FightNode_getResultList'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_FightNode_getResultList'", nullptr);
            return 0;
        }
        cocos2d::Vector<sgzj::FightResult *> ret = cobj->getResultList();
        ccvector_to_luaval(tolua_S, ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "sgzj.FightNode:getResultList",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_FightNode_getResultList'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_custom_FightNode_magicRatio(lua_State* tolua_S)
{
    int argc = 0;
    sgzj::FightNode* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"sgzj.FightNode",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (sgzj::FightNode*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_custom_FightNode_magicRatio'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_FightNode_magicRatio'", nullptr);
            return 0;
        }
        double ret = cobj->magicRatio();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "sgzj.FightNode:magicRatio",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_FightNode_magicRatio'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_custom_FightNode_phyDefence(lua_State* tolua_S)
{
    int argc = 0;
    sgzj::FightNode* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"sgzj.FightNode",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (sgzj::FightNode*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_custom_FightNode_phyDefence'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_FightNode_phyDefence'", nullptr);
            return 0;
        }
        double ret = cobj->phyDefence();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "sgzj.FightNode:phyDefence",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_FightNode_phyDefence'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_custom_FightNode_nodeId(lua_State* tolua_S)
{
    int argc = 0;
    sgzj::FightNode* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"sgzj.FightNode",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (sgzj::FightNode*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_custom_FightNode_nodeId'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_FightNode_nodeId'", nullptr);
            return 0;
        }
        int ret = cobj->nodeId();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "sgzj.FightNode:nodeId",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_FightNode_nodeId'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_custom_FightNode_damage(lua_State* tolua_S)
{
    int argc = 0;
    sgzj::FightNode* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"sgzj.FightNode",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (sgzj::FightNode*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_custom_FightNode_damage'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_FightNode_damage'", nullptr);
            return 0;
        }
        double ret = cobj->damage();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "sgzj.FightNode:damage",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_FightNode_damage'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_custom_FightNode_phyAttack(lua_State* tolua_S)
{
    int argc = 0;
    sgzj::FightNode* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"sgzj.FightNode",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (sgzj::FightNode*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_custom_FightNode_phyAttack'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_FightNode_phyAttack'", nullptr);
            return 0;
        }
        double ret = cobj->phyAttack();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "sgzj.FightNode:phyAttack",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_FightNode_phyAttack'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_custom_FightNode_health(lua_State* tolua_S)
{
    int argc = 0;
    sgzj::FightNode* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"sgzj.FightNode",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (sgzj::FightNode*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_custom_FightNode_health'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_FightNode_health'", nullptr);
            return 0;
        }
        double ret = cobj->health();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "sgzj.FightNode:health",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_FightNode_health'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_custom_FightNode_setStandPos(lua_State* tolua_S)
{
    int argc = 0;
    sgzj::FightNode* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"sgzj.FightNode",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (sgzj::FightNode*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_custom_FightNode_setStandPos'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        cocos2d::Point arg0;

        ok &= luaval_to_point(tolua_S, 2, &arg0, "sgzj.FightNode:setStandPos");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_FightNode_setStandPos'", nullptr);
            return 0;
        }
        cobj->setStandPos(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "sgzj.FightNode:setStandPos",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_FightNode_setStandPos'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_custom_FightNode_standPos(lua_State* tolua_S)
{
    int argc = 0;
    sgzj::FightNode* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"sgzj.FightNode",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (sgzj::FightNode*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_custom_FightNode_standPos'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_FightNode_standPos'", nullptr);
            return 0;
        }
        cocos2d::Point ret = cobj->standPos();
        point_to_luaval(tolua_S, ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "sgzj.FightNode:standPos",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_FightNode_standPos'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_custom_FightNode_magicAttack(lua_State* tolua_S)
{
    int argc = 0;
    sgzj::FightNode* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"sgzj.FightNode",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (sgzj::FightNode*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_custom_FightNode_magicAttack'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_FightNode_magicAttack'", nullptr);
            return 0;
        }
        double ret = cobj->magicAttack();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "sgzj.FightNode:magicAttack",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_FightNode_magicAttack'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_custom_FightNode_phyRatio(lua_State* tolua_S)
{
    int argc = 0;
    sgzj::FightNode* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"sgzj.FightNode",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (sgzj::FightNode*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_custom_FightNode_phyRatio'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_FightNode_phyRatio'", nullptr);
            return 0;
        }
        double ret = cobj->phyRatio();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "sgzj.FightNode:phyRatio",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_FightNode_phyRatio'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_custom_FightNode_isDead(lua_State* tolua_S)
{
    int argc = 0;
    sgzj::FightNode* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"sgzj.FightNode",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (sgzj::FightNode*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_custom_FightNode_isDead'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_FightNode_isDead'", nullptr);
            return 0;
        }
        bool ret = cobj->isDead();
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "sgzj.FightNode:isDead",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_FightNode_isDead'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_custom_FightNode_magicDefence(lua_State* tolua_S)
{
    int argc = 0;
    sgzj::FightNode* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"sgzj.FightNode",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (sgzj::FightNode*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_custom_FightNode_magicDefence'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_FightNode_magicDefence'", nullptr);
            return 0;
        }
        double ret = cobj->magicDefence();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "sgzj.FightNode:magicDefence",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_FightNode_magicDefence'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_custom_FightNode_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"sgzj.FightNode",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 7)
    {
        int arg0;
        double arg1;
        double arg2;
        double arg3;
        double arg4;
        double arg5;
        double arg6;
        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "sgzj.FightNode:create");
        ok &= luaval_to_number(tolua_S, 3,&arg1, "sgzj.FightNode:create");
        ok &= luaval_to_number(tolua_S, 4,&arg2, "sgzj.FightNode:create");
        ok &= luaval_to_number(tolua_S, 5,&arg3, "sgzj.FightNode:create");
        ok &= luaval_to_number(tolua_S, 6,&arg4, "sgzj.FightNode:create");
        ok &= luaval_to_number(tolua_S, 7,&arg5, "sgzj.FightNode:create");
        ok &= luaval_to_number(tolua_S, 8,&arg6, "sgzj.FightNode:create");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_FightNode_create'", nullptr);
            return 0;
        }
        sgzj::FightNode* ret = sgzj::FightNode::create(arg0, arg1, arg2, arg3, arg4, arg5, arg6);
        object_to_luaval<sgzj::FightNode>(tolua_S, "sgzj.FightNode",(sgzj::FightNode*)ret);
        return 1;
    }
    if (argc == 8)
    {
        int arg0;
        double arg1;
        double arg2;
        double arg3;
        double arg4;
        double arg5;
        double arg6;
        double arg7;
        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "sgzj.FightNode:create");
        ok &= luaval_to_number(tolua_S, 3,&arg1, "sgzj.FightNode:create");
        ok &= luaval_to_number(tolua_S, 4,&arg2, "sgzj.FightNode:create");
        ok &= luaval_to_number(tolua_S, 5,&arg3, "sgzj.FightNode:create");
        ok &= luaval_to_number(tolua_S, 6,&arg4, "sgzj.FightNode:create");
        ok &= luaval_to_number(tolua_S, 7,&arg5, "sgzj.FightNode:create");
        ok &= luaval_to_number(tolua_S, 8,&arg6, "sgzj.FightNode:create");
        ok &= luaval_to_number(tolua_S, 9,&arg7, "sgzj.FightNode:create");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_FightNode_create'", nullptr);
            return 0;
        }
        sgzj::FightNode* ret = sgzj::FightNode::create(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7);
        object_to_luaval<sgzj::FightNode>(tolua_S, "sgzj.FightNode",(sgzj::FightNode*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "sgzj.FightNode:create",argc, 7);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_FightNode_create'.",&tolua_err);
#endif
    return 0;
}
static int lua_cocos2dx_custom_FightNode_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (FightNode)");
    return 0;
}

int lua_register_cocos2dx_custom_FightNode(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"sgzj.FightNode");
    tolua_cclass(tolua_S,"FightNode","sgzj.FightNode","cc.Ref",nullptr);

    tolua_beginmodule(tolua_S,"FightNode");
        tolua_function(tolua_S,"AddFightResult",lua_cocos2dx_custom_FightNode_AddFightResult);
        tolua_function(tolua_S,"setDamage",lua_cocos2dx_custom_FightNode_setDamage);
        tolua_function(tolua_S,"mergeDamage",lua_cocos2dx_custom_FightNode_mergeDamage);
        tolua_function(tolua_S,"getResultList",lua_cocos2dx_custom_FightNode_getResultList);
        tolua_function(tolua_S,"magicRatio",lua_cocos2dx_custom_FightNode_magicRatio);
        tolua_function(tolua_S,"phyDefence",lua_cocos2dx_custom_FightNode_phyDefence);
        tolua_function(tolua_S,"nodeId",lua_cocos2dx_custom_FightNode_nodeId);
        tolua_function(tolua_S,"damage",lua_cocos2dx_custom_FightNode_damage);
        tolua_function(tolua_S,"phyAttack",lua_cocos2dx_custom_FightNode_phyAttack);
        tolua_function(tolua_S,"health",lua_cocos2dx_custom_FightNode_health);
        tolua_function(tolua_S,"setStandPos",lua_cocos2dx_custom_FightNode_setStandPos);
        tolua_function(tolua_S,"standPos",lua_cocos2dx_custom_FightNode_standPos);
        tolua_function(tolua_S,"magicAttack",lua_cocos2dx_custom_FightNode_magicAttack);
        tolua_function(tolua_S,"phyRatio",lua_cocos2dx_custom_FightNode_phyRatio);
        tolua_function(tolua_S,"isDead",lua_cocos2dx_custom_FightNode_isDead);
        tolua_function(tolua_S,"magicDefence",lua_cocos2dx_custom_FightNode_magicDefence);
        tolua_function(tolua_S,"create", lua_cocos2dx_custom_FightNode_create);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(sgzj::FightNode).name();
    g_luaType[typeName] = "sgzj.FightNode";
    g_typeCast["FightNode"] = "sgzj.FightNode";
    return 1;
}

int lua_cocos2dx_custom_FightManager_removeFightNode(lua_State* tolua_S)
{
    int argc = 0;
    sgzj::FightManager* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"sgzj.FightManager",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (sgzj::FightManager*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_custom_FightManager_removeFightNode'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        sgzj::FightNode* arg0;

        ok &= luaval_to_object<sgzj::FightNode>(tolua_S, 2, "sgzj.FightNode",&arg0, "sgzj.FightManager:removeFightNode");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_FightManager_removeFightNode'", nullptr);
            return 0;
        }
        cobj->removeFightNode(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "sgzj.FightManager:removeFightNode",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_FightManager_removeFightNode'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_custom_FightManager_handleAttack(lua_State* tolua_S)
{
    int argc = 0;
    sgzj::FightManager* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"sgzj.FightManager",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (sgzj::FightManager*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_custom_FightManager_handleAttack'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 5) 
    {
        sgzj::FightNode* arg0;
        sgzj::FightNode* arg1;
        int arg2;
        double arg3;
        bool arg4;

        ok &= luaval_to_object<sgzj::FightNode>(tolua_S, 2, "sgzj.FightNode",&arg0, "sgzj.FightManager:handleAttack");

        ok &= luaval_to_object<sgzj::FightNode>(tolua_S, 3, "sgzj.FightNode",&arg1, "sgzj.FightManager:handleAttack");

        ok &= luaval_to_int32(tolua_S, 4,(int *)&arg2, "sgzj.FightManager:handleAttack");

        ok &= luaval_to_number(tolua_S, 5,&arg3, "sgzj.FightManager:handleAttack");

        ok &= luaval_to_boolean(tolua_S, 6,&arg4, "sgzj.FightManager:handleAttack");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_FightManager_handleAttack'", nullptr);
            return 0;
        }
        cobj->handleAttack(arg0, arg1, arg2, arg3, arg4);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "sgzj.FightManager:handleAttack",argc, 5);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_FightManager_handleAttack'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_custom_FightManager_addFightNode(lua_State* tolua_S)
{
    int argc = 0;
    sgzj::FightManager* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"sgzj.FightManager",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (sgzj::FightManager*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_custom_FightManager_addFightNode'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        sgzj::FightNode* arg0;

        ok &= luaval_to_object<sgzj::FightNode>(tolua_S, 2, "sgzj.FightNode",&arg0, "sgzj.FightManager:addFightNode");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_FightManager_addFightNode'", nullptr);
            return 0;
        }
        cobj->addFightNode(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "sgzj.FightManager:addFightNode",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_FightManager_addFightNode'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_custom_FightManager_handleAOE(lua_State* tolua_S)
{
    int argc = 0;
    sgzj::FightManager* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"sgzj.FightManager",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (sgzj::FightManager*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_custom_FightManager_handleAOE'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 4) 
    {
        sgzj::FightNode* arg0;
        int arg1;
        double arg2;
        double arg3;

        ok &= luaval_to_object<sgzj::FightNode>(tolua_S, 2, "sgzj.FightNode",&arg0, "sgzj.FightManager:handleAOE");

        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1, "sgzj.FightManager:handleAOE");

        ok &= luaval_to_number(tolua_S, 4,&arg2, "sgzj.FightManager:handleAOE");

        ok &= luaval_to_number(tolua_S, 5,&arg3, "sgzj.FightManager:handleAOE");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_FightManager_handleAOE'", nullptr);
            return 0;
        }
        cobj->handleAOE(arg0, arg1, arg2, arg3);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "sgzj.FightManager:handleAOE",argc, 4);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_FightManager_handleAOE'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_custom_FightManager_flushDamage(lua_State* tolua_S)
{
    int argc = 0;
    sgzj::FightManager* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"sgzj.FightManager",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (sgzj::FightManager*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_custom_FightManager_flushDamage'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_FightManager_flushDamage'", nullptr);
            return 0;
        }
        cobj->flushDamage();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "sgzj.FightManager:flushDamage",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_FightManager_flushDamage'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_custom_FightManager_getInstance(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"sgzj.FightManager",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_FightManager_getInstance'", nullptr);
            return 0;
        }
        sgzj::FightManager* ret = sgzj::FightManager::getInstance();
        object_to_luaval<sgzj::FightManager>(tolua_S, "sgzj.FightManager",(sgzj::FightManager*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "sgzj.FightManager:getInstance",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_FightManager_getInstance'.",&tolua_err);
#endif
    return 0;
}
static int lua_cocos2dx_custom_FightManager_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (FightManager)");
    return 0;
}

int lua_register_cocos2dx_custom_FightManager(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"sgzj.FightManager");
    tolua_cclass(tolua_S,"FightManager","sgzj.FightManager","cc.Ref",nullptr);

    tolua_beginmodule(tolua_S,"FightManager");
        tolua_function(tolua_S,"removeFightNode",lua_cocos2dx_custom_FightManager_removeFightNode);
        tolua_function(tolua_S,"handleAttack",lua_cocos2dx_custom_FightManager_handleAttack);
        tolua_function(tolua_S,"addFightNode",lua_cocos2dx_custom_FightManager_addFightNode);
        tolua_function(tolua_S,"handleAOE",lua_cocos2dx_custom_FightManager_handleAOE);
        tolua_function(tolua_S,"flushDamage",lua_cocos2dx_custom_FightManager_flushDamage);
        tolua_function(tolua_S,"getInstance", lua_cocos2dx_custom_FightManager_getInstance);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(sgzj::FightManager).name();
    g_luaType[typeName] = "sgzj.FightManager";
    g_typeCast["FightManager"] = "sgzj.FightManager";
    return 1;
}
TOLUA_API int register_all_cocos2dx_custom(lua_State* tolua_S)
{
	tolua_open(tolua_S);
	
	tolua_module(tolua_S,"sgzj",0);
	tolua_beginmodule(tolua_S,"sgzj");

	lua_register_cocos2dx_custom_FightManager(tolua_S);
	lua_register_cocos2dx_custom_FightResult(tolua_S);
	lua_register_cocos2dx_custom_FightNode(tolua_S);

	tolua_endmodule(tolua_S);
	return 1;
}

