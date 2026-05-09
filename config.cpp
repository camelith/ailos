class CfgPatches
{
    class AILOS_Forget
    {
        units[] = {};
        weapons[] = {};
        name = "AILOS";
        requiredAddons[] = { "A3_Data_F", "A3_Characters_F", "cba_main" };
        author = "99% of this is Nicemman's work from Enhanced Tactical AI & TCL Revamp";
    };
};

class CfgFunctions
{
    class AILOS
    {
        class core
        {
            file = "\ailos\functions";

            class processGroup     {};
            class canSeeEnemy      {};
            class pickPrimaryEnemy {};
            class soundAlert       {};
            class mainLoop         {};
            class skill            {};
        };
    };
};

class Extended_PreInit_EventHandlers
{
    class AILOS_PreInit
    {
        init = "call compile preProcessFileLineNumbers '\ailos\XEH_preInit.sqf'";
    };
};

class Extended_PostInit_EventHandlers
{
    class AILOS_PostInit
    {
        init = "call compile preProcessFileLineNumbers '\ailos\XEH_postInit.sqf'";
    };
};
