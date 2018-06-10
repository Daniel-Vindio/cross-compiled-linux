# The Multiarch Wrapper is used to wrap certain binaries that have 
# hardcoded paths to libraries or are architecture specific.


function registro_error () {
#Función para registrar errores y resultados en la bitaćora
if [ $? -ne 0 ]
then
	MOMENTO=$(date)
	echo $MSG_ERR
	echo "$MOMENTO $nombre <$1> -> ERROR" >> $FILE_BITACORA
	exit 1
else
	MOMENTO=$(date)
	echo "$MOMENTO $nombre <$1> -> Conforme" >> $FILE_BITACORA
fi
}

echo -e "\nInstalacion de MULTI ARCH WRAPPER." >> $FILE_BITACORA

cat > multiarch_wrapper.c << "EOF"
#define _GNU_SOURCE

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#ifndef DEF_SUFFIX
#  define DEF_SUFFIX "64"
#endif

int main(int argc, char **argv)
{
  char *filename;
  char *suffix;

  if(!(suffix = getenv("USE_ARCH")))
    if(!(suffix = getenv("BUILDENV")))
      suffix = DEF_SUFFIX;

  if (asprintf(&filename, "%s-%s", argv[0], suffix) < 0) {
    perror(argv[0]);
    return -1;
  }

  int status = EXIT_FAILURE;
  pid_t pid = fork();

  if (pid == 0) {
    execvp(filename, argv);
    perror(filename);
  } else if (pid < 0) {
    perror(argv[0]);
  } else {
    if (waitpid(pid, &status, 0) != pid) {
      status = EXIT_FAILURE;
      perror(argv[0]);
    } else {
      status = WEXITSTATUS(status);
    }
  }

  free(filename);

  return status;
}

EOF

registro_error "cat > multiarch_wrapper.c"

gcc ${BUILD64} multiarch_wrapper.c -o /usr/bin/multiarch_wrapper
registro_error "gcc ${BUILD64} multiarch_wrapper.c..."


echo 'echo "32bit Version"' > test-32
echo 'echo "64bit Version"' > test-64
chmod -v 755 test-32 test-64
ln -sv /usr/bin/multiarch_wrapper test

USE_ARCH=32 ./test &>> $FILE_BITACORA
USE_ARCH=64 ./test &>> $FILE_BITACORA

rm -v multiarch_wrapper.c test{,-32,-64}
