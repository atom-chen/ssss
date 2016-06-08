#include "lua_cocos2dx_custom_auto.hpp"
#include "RouteFinder.hpp"
#include "RoleNode.hpp"
#include "tolua_fix.h"
#include "LuaBasicConversions.h"


int lua_cocos2dx_custom_RouteData_loadRouteData(lua_State* tolua_S)
{
    int argc = 0;
    sgzj::RouteData* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"sgzj.RouteData",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (sgzj::RouteData*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_custom_RouteData_loadRouteData'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        std::string arg0;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "sgzj.RouteData:loadRouteData");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_RouteData_loadRouteData'", nullptr);
            return 0;
        }
        cobj->loadRouteData(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "sgzj.RouteData:loadRouteData",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_RouteData_loadRouteData'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_custom_RouteData_clear(lua_State* tolua_S)
{
    int argc = 0;
    sgzj::RouteData* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"sgzj.RouteData",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (sgzj::RouteData*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_custom_RouteData_clear'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_RouteData_clear'", nullptr);
            return 0;
        }
        cobj->clear();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "sgzj.RouteData:clear",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_RouteData_clear'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_custom_RouteData_debugDraw(lua_State* tolua_S)
{
    int argc = 0;
    sgzj::RouteData* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"sgzj.RouteData",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (sgzj::RouteData*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_custom_RouteData_debugDraw'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        cocos2d::DrawNode* arg0;

        ok &= luaval_to_object<cocos2d::DrawNode>(tolua_S, 2, "cc.DrawNode",&arg0, "sgzj.RouteData:debugDraw");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_RouteData_debugDraw'", nullptr);
            return 0;
        }
        cobj->debugDraw(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "sgzj.RouteData:debugDraw",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_RouteData_debugDraw'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_custom_RouteData_loadRouteConfig(lua_State* tolua_S)
{
    int argc = 0;
    sgzj::RouteData* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"sgzj.RouteData",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (sgzj::RouteData*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_custom_RouteData_loadRouteConfig'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        std::string arg0;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "sgzj.RouteData:loadRouteConfig");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_RouteData_loadRouteConfig'", nullptr);
            return 0;
        }
        cobj->loadRouteConfig(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "sgzj.RouteData:loadRouteConfig",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_RouteData_loadRouteConfig'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_custom_RouteData_getInstance(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"sgzj.RouteData",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_RouteData_getInstance'", nullptr);
            return 0;
        }
        sgzj::RouteData* ret = sgzj::RouteData::getInstance();
        object_to_luaval<sgzj::RouteData>(tolua_S, "sgzj.RouteData",(sgzj::RouteData*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "sgzj.RouteData:getInstance",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_RouteData_getInstance'.",&tolua_err);
#endif
    return 0;
}
static int lua_cocos2dx_custom_RouteData_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (RouteData)");
    return 0;
}

int lua_register_cocos2dx_custom_RouteData(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"sgzj.RouteData");
    tolua_cclass(tolua_S,"RouteData","sgzj.RouteData","cc.Ref",nullptr);

    tolua_beginmodule(tolua_S,"RouteData");
        tolua_function(tolua_S,"loadRouteData",lua_cocos2dx_custom_RouteData_loadRouteData);
        tolua_function(tolua_S,"clear",lua_cocos2dx_custom_RouteData_clear);
        tolua_function(tolua_S,"debugDraw",lua_cocos2dx_custom_RouteData_debugDraw);
        tolua_function(tolua_S,"loadRouteConfig",lua_cocos2dx_custom_RouteData_loadRouteConfig);
        tolua_function(tolua_S,"getInstance", lua_cocos2dx_custom_RouteData_getInstance);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(sgzj::RouteData).name();
    g_luaType[typeName] = "sgzj.RouteData";
    g_typeCast["RouteData"] = "sgzj.RouteData";
    return 1;
}

int lua_cocos2dx_custom_RoleNode_findRoute(lua_State* tolua_S)
{
    int argc = 0;
    sgzj::RoleNode* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"sgzj.RoleNode",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (sgzj::RoleNode*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_custom_RoleNode_findRoute'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        cocos2d::Point arg0;

        ok &= luaval_to_point(tolua_S, 2, &arg0, "sgzj.RoleNode:findRoute");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_RoleNode_findRoute'", nullptr);
            return 0;
        }
        cobj->findRoute(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "sgzj.RoleNode:findRoute",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_RoleNode_findRoute'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_custom_RoleNode_setStartPoint(lua_State* tolua_S)
{
    int argc = 0;
    sgzj::RoleNode* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"sgzj.RoleNode",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (sgzj::RoleNode*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_custom_RoleNode_setStartPoint'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        cocos2d::Point arg0;

        ok &= luaval_to_point(tolua_S, 2, &arg0, "sgzj.RoleNode:setStartPoint");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_RoleNode_setStartPoint'", nullptr);
            return 0;
        }
        cobj->setStartPoint(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "sgzj.RoleNode:setStartPoint",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_RoleNode_setStartPoint'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_custom_RoleNode_drawRoutePath(lua_State* tolua_S)
{
    int argc = 0;
    sgzj::RoleNode* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"sgzj.RoleNode",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (sgzj::RoleNode*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_custom_RoleNode_drawRoutePath'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        cocos2d::DrawNode* arg0;

        ok &= luaval_to_object<cocos2d::DrawNode>(tolua_S, 2, "cc.DrawNode",&arg0, "sgzj.RoleNode:drawRoutePath");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_RoleNode_drawRoutePath'", nullptr);
            return 0;
        }
        cobj->drawRoutePath(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "sgzj.RoleNode:drawRoutePath",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_RoleNode_drawRoutePath'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_custom_RoleNode_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"sgzj.RoleNode",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_RoleNode_create'", nullptr);
            return 0;
        }
        sgzj::RoleNode* ret = sgzj::RoleNode::create();
        object_to_luaval<sgzj::RoleNode>(tolua_S, "sgzj.RoleNode",(sgzj::RoleNode*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "sgzj.RoleNode:create",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_RoleNode_create'.",&tolua_err);
#endif
    return 0;
}
static int lua_cocos2dx_custom_RoleNode_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (RoleNode)");
    return 0;
}

int lua_register_cocos2dx_custom_RoleNode(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"sgzj.RoleNode");
    tolua_cclass(tolua_S,"RoleNode","sgzj.RoleNode","cc.Node",nullptr);

    tolua_beginmodule(tolua_S,"RoleNode");
        tolua_function(tolua_S,"findRoute",lua_cocos2dx_custom_RoleNode_findRoute);
        tolua_function(tolua_S,"setStartPoint",lua_cocos2dx_custom_RoleNode_setStartPoint);
        tolua_function(tolua_S,"drawRoutePath",lua_cocos2dx_custom_RoleNode_drawRoutePath);
        tolua_function(tolua_S,"create", lua_cocos2dx_custom_RoleNode_create);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(sgzj::RoleNode).name();
    g_luaType[typeName] = "sgzj.RoleNode";
    g_typeCast["RoleNode"] = "sgzj.RoleNode";
    return 1;
}
TOLUA_API int register_all_cocos2dx_custom(lua_State* tolua_S)
{
	tolua_open(tolua_S);
	
	tolua_module(tolua_S,"sgzj",0);
	tolua_beginmodule(tolua_S,"sgzj");

	lua_register_cocos2dx_custom_RoleNode(tolua_S);
	lua_register_cocos2dx_custom_RouteData(tolua_S);

	tolua_endmodule(tolua_S);
	return 1;
}

