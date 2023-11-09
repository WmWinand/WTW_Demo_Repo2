**************************************************************;
* Demo 3.01: Exploring and Managing a CAS Session            *;
* NOTE: If you have not setup the Autoexec file in           *;
*       SAS Studio, open and submit startup.sas first.       *;
**************************************************************;

*******************************;
* Step 1 - Session Action Set *;
*******************************;

*****;
* a *;
*****;
proc cas;
    session.listSessions;
quit;


*****;
* b *;
*****;
proc cas;
    session.sessionStatus;
quit;


*****;
* c *;
*****;
proc cas;
    session.metrics / on=True;
quit;



***********************************;
* Step 2 - SessionProp Action Set *;
***********************************;

*****;
* a *;
*****;
proc cas;
    sessionProp.listSessOpts;
quit;


*****;
* b *;
*****;
proc cas;
    sessionProp.getSessOpt / name="metrics";
    sessionProp.getSessOpt / name="timeout";
    sessionProp.getSessOpt / name="caslib";
quit;


*****;
* c *;
*****;
proc cas;
  props={timeout=20000, metrics=False};
* Set session options *;
    sessionProp.setSessOpt / props;

* View session options *;
    sessionProp.getSessOpt / name="metrics";
    sessionProp.getSessOpt / name="timeout";
quit;



********************************;
* Step 3 - Builtins Action Set *;
********************************;

*****;
* a *;
*****;
proc cas;
    builtins.serverStatus;
quit;


*****;
* b *;
*****;
proc cas;
    builtins.getLicensedProductInfo;
quit;

proc cas;
    builtins.getLicenseInfo;
quit;


*****;
* c *;
*****;
proc cas;
    builtins.actionSetInfo;
quit;


*****;
* d *;
*****;
proc cas;
    builtins.actionSetInfo / all=True;
quit;


*****;
* e *;
*****;
proc cas;
    builtins.help / actionSet="builtins", action="actionSetInfo";
quit;
