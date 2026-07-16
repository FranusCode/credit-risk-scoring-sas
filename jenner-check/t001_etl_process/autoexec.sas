/* cap input rows for the captured run */
options obs=100;

/* upstream points bank at a hardcoded local path
   (/home/u64365845/projekt); here it's a Jenner work-local libname that
   script.sas populates itself via inline DATALINES, so the bundle has
   no external dependency at all */
libname bank (work);
