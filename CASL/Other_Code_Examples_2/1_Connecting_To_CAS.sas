/* SESSION ACTION SET */

/* list sessions */
proc cas;
  session.listSessions;
quit;

/* status and info of current session */
proc cas;
  session.sessionStatus;
quit;

/* session metrics - turn on or off for more info */
proc cas;
  session.metrics / on=True;
quit;

/* SESSIONPROP ACTION SET FOR MANAGING SESSION PROPERTIES */

/* list session options */
proc cas;
  sessionProp.listSessOpts;
quit;

proc cas;
  sessionProp.getSessOpt / name="metrics";
  sessionProp.getSessOpt / name="timeout";
  sessionProp.getSessOpt / name="caslib";
quit;

/* set session options */
proc cas;
  sessionProp.setSessOpt / timeout=20000, metrics=False;

  sessionProp.getSessOpt / name="metrics";
  sessionProp.getSessOpt / name="timeout";
quit;

/* BUILTINS ACTION SET - FOR SERVER MANAGEMENT */

/* get server status */
proc cas;
  builtins.serverStatus;
quit;

/* get licensed product and license info */
proc cas;
  builtins.getLicensedProductInfo;
  builtins.getLicenseInfo;
quit;

/* get info on all loaded action sets */
proc cas;
  builtins.actionSetInfo;
quit;

/* get info on all available action sets */
proc cas;
  builtins.actionSetInfo / all=True;
quit;

/* get more info on a specific action */
proc cas;
  builtins.help / actionSet="builtins", action="actionSetInfo";
quit;
