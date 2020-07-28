
# Script to be sourced by kb-s2i
# Does the following highlevel setup:
# 1. Copies the fcgid-access-checker to application image
# 2. Places configuration for the access checkers on the application image 
# 3. Copies httpd configuration for the various checkers
# 4. Creates structure for mounting content 

cp -rp $S2I_SRC_ROOT/fcgid-access-checker $APP_BASE/.

mv $APP_BASE/fcgid-access-checker/*.ini $APP_BASE/conf/.

CHECKERS='download stream thumbnails tv-thumbnails'

for CHECKER in $CHECKERS 
do
    ln -s $APP_BASE/conf/$CHECKER-check.ini $APP_BASE/fcgid-access-checker/.
done

cp $S2I_SCR_ROOT/ocp-conf/* $HTTPD_CONFIGURATION_PATH/.

CONTENT_BASE=$APP_BASE/content
mkdir $CONTENT_BASE
mkdir $CONTENT_BASE/{pdfs,jp2,tv-thumbnails}



