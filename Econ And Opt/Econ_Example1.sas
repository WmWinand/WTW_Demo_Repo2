cas mySession sessopts=(caslib=casuser timeout=1800 locale="en_us" metrics=FALSE);
libname mycas cas caslib=casuser;

data mycas.websites(label="Transactional internet data");

   /*- time variable definition -*/
       keep time;
       format time datetime.;
       label time="Time of Web Hit";
       starttime = '12mar2000:00:00:00'dt; /*- Sunday -*/
       seedtime = 1234321;

   /*- cars variable definition -*/
       keep cars;
       format cars best12.;
       label cars="Number of Car Web Hits";
       seedcar = 1234321;

   /*- boats variable definition -*/
       keep boats;
       format boats best12.;
       label boats="Number of Boat Web Hits";
       seedboat = 1234321;

   /*- planes variable definition -*/
       keep planes;
       format planes best12.;
       label planes="Number of Planes Web Hits";
       seedplane = 1234321;

   /*- engines variable definition -*/
       keep engines;
       format engines best12.;
       label engines="Number of Engine Web Hits";
       seedengine = 1234321;

   /*- simulate the data -*/
       do day = 1 to 30;
          season = abs(4 - mod(day,7));
          nhits = ceil(10*ranuni(seedtime));
          intv = 24*3600*ranuni(seedtime)/nhits;
          do hits = 1 to nhits;

          /*- randomly generate the next time -*/
              intv = intv + 24*3600*ranuni(seedtime)/nhits;
              intv = int(intv);
              time = intnx( 'DTDAY', starttime, day );
              time = intnx( 'DTSECOND', time, intv );

          /*- randomly generate car data -*/
               cars = 1000 + 600*day + 1000*season
                    + 10*rannor(seedcar);
               cars = int(cars);

          /*- randomly generate boats data -*/
              boats = 1000 + 1000*season +
                    + 10*rannor(seedboat);
              boats = int(boats);

          /*- randomly generate planes data -*/
              planes = 1000 - 10*day +
                     + 10*rannor(seedplane);
              planes = int(planes);

          /*- randomly generate engines data -*/
              engines = 1000 + 1*cars - 2*boats + 4*planes
                      + 10*rannor(seedengine);
              engines = int(engines);

             output;
         end;
      end;

run;

proc cesm data=mycas.websites outfor=mycas.nextweek;
   id time interval=dtday accumulate=total;
   forecast boats cars planes / lead=7 method=simple;
run;

%macro plotActualPredict(ds,timeId,var,refValue,
                         xStart,xEnd,xBy,xLabel,yStart,yEnd,yBy,yLabel);
   proc sgplot data=&ds.(where=(_name_="&var."));
      series x=&timeId. y=actual / markers lineattrs=(color=red)
         markerattrs=(symbol=circlefilled color=red);
      series x=&timeId. y=predict / markers lineattrs=(color=blue)
         markerattrs=(symbol=asterisk color=blue);
      refline &refValue. / axis=x;
      xaxis values=(&xStart. to &xEnd. by &xBy.) label=&xLabel;
      yaxis values=(&yStart. to &yEnd. by &yBy.) label=&yLabel minor;
   run;
%mend;

%plotActualPredict(mycas.nextweek, time, boats, '11APR2000:00:00:00'dt,
   '13MAR2000:00:00:00'dt, '18APR2000:00:00:00'dt, dtweek, 'Time of Web Hit',
   0, 50000, 10000, 'Web Hits');

%plotActualPredict(mycas.nextweek, time, cars, '11APR2000:00:00:00'dt,
   '13MAR2000:00:00:00'dt, '18APR2000:00:00:00'dt, dtweek, 'Time of Web Hit',
   0, 250000, 50000, 'Web Hits');

%plotActualPredict(mycas.nextweek, time, planes, '11APR2000:00:00:00'dt,
   '13MAR2000:00:00:00'dt, '18APR2000:00:00:00'dt, dtweek, 'Time of Web Hit',
   0, 12000, 2000, 'Web Hits');