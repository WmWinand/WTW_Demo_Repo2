/*****************************************************************************/
/* ViyaPgm_02: Create a SAS librefs for existing caslibs                     */
/*****************************************************************************/

/*****************************************************************************/
/* RUN THIS CODE SECTION IF YOU DID NOT RUN ViyaPgm_01 PREVIOUSLY            */
/*                                                                           */
/* ViyaPgm_01: Create a CAS Connection & Start a CAS Session                 */
/*****************************************************************************/
/* options cashost="127.0.0.1" casport=5570; */
cas mySession sessopts=(caslib=casuser timeout=1800 locale="en_US");


/*****************************************************************************/
/*  Create SAS librefs for existing caslibs                                  */
/*  so that they are visible in the SAS Studio Libraries tree.               */
/*  Create a separate libref for the casuser caslib                          */
/*****************************************************************************/

caslib _all_ assign;
caslib _all_ list;

libname mycas cas caslib=casuser;
