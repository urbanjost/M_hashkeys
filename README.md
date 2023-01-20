<!--
![sample](docs/images/snap2b.gif)
-->

NOTE: This repository requires being built with fpm ( [Fortran Package Manager](https://github.com/fortran-lang/fpm) )
      Alternatively, it may be found as a part of the GPF( [General Purpose Fortran](https://github.com/urbanjost/general-purpose-fortran) )

## Name

### M_hashkeys - a collection of hash key generator modules

## Description

   M_hashkeys(3f) is a Fortran repository that contains several modules 
   of hash generators.

## Documentation   ![docs](docs/images/docs.gif)
### User

All documents are contained in the docs/ directory including
archive files of man(1) pages that can be installed on ULS
(Unix-Like Systems).

#### Individual man-pages as HTML

   HTML versions of the man-pages describe all the routines:
   - An [index](https://urbanjost.github.io/M_hashkeys/man3.html) to M_hashkeys.f90 and M_sha3.f90 

#### All man-pages amalgamated as HTML

   Another view of these documents (that uses javascript to combine all
   the HTML descriptions of the man-pages) is in a form that can easily be printed as a single document.
   - [*BOOK_M_hashkeys*](https://urbanjost.github.io/M_hashkeys/BOOK_M_hashkeys.html) 
   - [*BOOK_M_sha3*](https://urbanjost.github.io/M_hashkeys/BOOK_M_sha3.html) 

### real man-pages ![gmake](docs/images/manpages.gif)

   + [manpages.zip](https://urbanjost.github.io/M_hashkeys/manpages.zip)
   + [manpages.tgz](https://urbanjost.github.io/M_hashkeys/manpages.tgz)

   - [CHANGELOG](docs/CHANGELOG.md) provides a history of significant changes
### Developer 

   - [doxygen(1) output](https://urbanjost.github.io/M_hashkeys/doxygen_out/html/index.html).
   - [ford(1) output](https://urbanjost.github.io/M_hashkeys/fpm-ford/index.html).
   - [github action status](docs/STATUS.md) 

## Download and Build

<!--
### gmake ![gmake](docs/images/gnu.gif)

   ```bash
       git clone https://github.com/urbanjost/M_hashkeys.git
       cd M_hashkeys/src
       # change Makefile if not using one of the listed compilers
       make clean; make gfortran    # for gfortran
       make clean; make ifort       # for ifort
       make clean; make nvfortran   # for nvfortran
   ```
   This will compile the M_hashkeys module and example programs.
-->

### fpm ![fpm](docs/images/fpm_logo.gif)

   Download the github repository and build it with
   fpm ( as described at [Fortran Package Manager](https://github.com/fortran-lang/fpm) )

   ```bash
        git clone https://github.com/urbanjost/M_hashkeys.git
        cd M_hashkeys
        fpm test
   ```

   or just list it as a dependency in your fpm.toml project file.

```toml
        [dependencies]
        M_hashkeys        = { git = "https://github.com/urbanjost/M_hashkeys.git" }
```

---
