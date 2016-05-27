#include "lua_cocos2dx_custom_auto.hpp"
#include "RouteFinder.hpp"
#include "tolua_fix.h"
#include "LuaBasicConversions.h"


int lua_cocos2dx_custom_Line_endPoint(lua_State* tolua_S)
{
    int argc = 0;
    sgzj::Line* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"sgzj.Line",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (sgzj::Line*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_custom_Line_endPoint'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_Line_endPoint'", nullptr);
            return 0;
        }
        cocos2d::Point& ret = cobj->endPoint();
        point_to_luaval(tolua_S, ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "sgzj.Line:endPoint",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_Line_endPoint'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_custom_Line_startPoint(lua_State* tolua_S)
{
    int argc = 0;
    sgzj::Line* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"sgzj.Line",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (sgzj::Line*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_custom_Line_startPoint'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_Line_startPoint'", nullptr);
            return 0;
        }
        cocos2d::Point& ret = cobj->startPoint();
        point_to_luaval(tolua_S, ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "sgzj.Line:startPoint",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_Line_startPoint'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_custom_Line_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"sgzj.Line",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 2)
    {
        cocos2d::Point arg0;
        cocos2d::Point arg1;
        ok &= luaval_to_point(tolua_S, 2, &arg0, "sgzj.Line:create");
        ok &= luaval_to_point(tolua_S, 3, &arg1, "sgzj.Line:create");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_Line_create'", nullptr);
            return 0;
        }
        sgzj::Line* ret = sgzj::Line::create(arg0, arg1);
        object_to_luaval<sgzj::Line>(tolua_S, "sgzj.Line",(sgzj::Line*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "sgzj.Line:create",argc, 2);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_Line_create'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_custom_Line_constructor(lua_State* tolua_S)
{
    int argc = 0;
    sgzj::Line* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif



    argc = lua_gettop(tolua_S)-1;
    if (argc == 2) 
    {
        cocos2d::Point arg0;
        cocos2d::Point arg1;

        ok &= luaval_to_point(tolua_S, 2, &arg0, "sgzj.Line:Line");

        ok &= luaval_to_point(tolua_S, 3, &arg1, "sgzj.Line:Line");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_Line_constructor'", nullptr);
            return 0;
        }
        cobj = new sgzj::Line(arg0, arg1);
        cobj->autorelease();
        int ID =  (int)cobj->_ID ;
        int* luaID =  &cobj->_luaID ;
        toluafix_pushusertype_ccobject(tolua_S, ID, luaID, (void*)cobj,"sgzj.Line");
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "sgzj.Line:Line",argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_Line_constructor'.",&tolua_err);
#endif

    return 0;
}

static int lua_cocos2dx_custom_Line_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (Line)");
    return 0;
}

int lua_register_cocos2dx_custom_Line(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"sgzj.Line");
    tolua_cclass(tolua_S,"Line","sgzj.Line","cc.Ref",nullptr);

    tolua_beginmodule(tolua_S,"Line");
        tolua_function(tolua_S,"new",lua_cocos2dx_custom_Line_constructor);
        tolua_function(tolua_S,"endPoint",lua_cocos2dx_custom_Line_endPoint);
        tolua_function(tolua_S,"startPoint",lua_cocos2dx_custom_Line_startPoint);
        tolua_function(tolua_S,"create", lua_cocos2dx_custom_Line_create);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(sgzj::Line).name();
    g_luaType[typeName] = "sgzj.Line";
    g_typeCast["Line"] = "sgzj.Line";
    return 1;
}

int lua_cocos2dx_custom_RouteFinder_findRoute(lua_State* tolua_S)
{
    int argc = 0;
    sgzj::RouteFinder* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"sgzj.RouteFinder",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (sgzj::RouteFinder*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_custom_RouteFinder_findRoute'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        cocos2d::Point arg0;

        ok &= luaval_to_point(tolua_S, 2, &arg0, "sgzj.RouteFinder:findRoute");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_RouteFinder_findRoute'", nullptr);
            return 0;
        }
        cobj->findRoute(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "sgzj.RouteFinder:findRoute",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_RouteFinder_findRoute'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_custom_RouteFinder_clear(lua_State* tolua_S)
{
    int argc = 0;
    sgzj::RouteFinder* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"sgzj.RouteFinder",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (sgzj::RouteFinder*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_custom_RouteFinder_clear'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_RouteFinder_clear'", nullptr);
            return 0;
        }
        cobj->clear();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "sgzj.RouteFinder:clear",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_RouteFinder_clear'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_custom_RouteFinder_currentRoutePath(lua_State* tolua_S)
{
    int argc = 0;
    sgzj::RouteFinder* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"sgzj.RouteFinder",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (sgzj::RouteFinder*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_custom_RouteFinder_currentRoutePath'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_RouteFinder_currentRoutePath'", nullptr);
            return 0;
        }
        cocos2d::Vector<sgzj::Line *>& ret = cobj->currentRoutePath();
        ccvector_to_luaval(tolua_S, ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "sgzj.RouteFinder:currentRoutePath",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_RouteFinder_currentRoutePath'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_custom_RouteFinder_getInstance(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"sgzj.RouteFinder",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_cocos2dx_custom_RouteFinder_getInstance'", nullptr);
            return 0;
        }
        sgzj::RouteFinder* ret = sgzj::RouteFinder::getInstance();
        object_to_luaval<sgzj::RouteFinder>(tolua_S, "sgzj.RouteFinder",(sgzj::RouteFinder*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "sgzj.RouteFinder:getInstance",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_custom_RouteFinder_getInstance'.",&tolua_err);
#endif
    return 0;
}
static int lua_cocos2dx_custom_RouteFinder_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (RouteFinder)");
    return 0;
}

int lua_register_cocos2dx_custom_RouteFinder(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"sgzj.RouteFinder");
    tolua_cclass(tolua_S,"RouteFinder","sgzj.RouteFinder","cc.Ref",nullptr);

    tolua_beginmodule(tolua_S,"RouteFinder");
        tolua_function(tolua_S,"findRoute",lua_cocos2dx_custom_RouteFinder_findRoute);
        tolua_function(tolua_S,"clear",lua_cocos2dx_custom_RouteFinder_clear);
        tolua_function(tolua_S,"currentRoutePath",lua_cocos2dx_custom_RouteFinder_currentRoutePath);
        tolua_function(tolua_S,"getInstance", lua_cocos2dx_custom_RouteFinder_getInstance);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(sgzj::RouteFinder).name();
    g_luaType[typeName] = "sgzj.RouteFinder";
    g_typeCast["RouteFinder"] = "sgzj.RouteFinder";
    return 1;
}
TOLUA_API int register_all_cocos2dx_custom(lua_State* tolua_S)
{
	tolua_open(tolua_S);
	
	tolua_module(tolua_S,"sgzj",0);
	tolua_beginmodule(tolua_S,"sgzj");

	lua_register_cocos2dx_custom_RouteFinder(tolua_S);
	lua_register_cocos2dx_custom_Line(tolua_S);

	tolua_endmodule(tolua_S);
	return 1;
}

