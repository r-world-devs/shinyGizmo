## Test environments
* local check
  Ubuntu Ubuntu 20.04.2 LTS, R 4.1.0 (2021-05-18)
* win-builder
  R version 4.1.3 (2022-03-10)
  R version 4.2.2 (2022-10-31 ucrt)
  R Under development (unstable) (2022-12-18 r83472 ucrt)

## `R CMD check shinyGizmo_0.4.tar.gz --as-cran` results

```
Status: OK
```

## `devtools::check()` results

```
0 errors ✓ | 0 warnings ✓ | 0 notes ✓
```

## win-builder result

```
* using log directory 'd:/RCompile/CRANguest/R-oldrelease/shinyGizmo.Rcheck'
* using R version 4.1.3 (2022-03-10)
* using platform: x86_64-w64-mingw32 (64-bit)
* using session charset: ISO8859-1
...
* checking CRAN incoming feasibility ... NOTE
Maintainer: 'Krystian Igras <krystian8207@gmail.com>'
...
Status: 1 NOTE
```

```
* using log directory 'd:/RCompile/CRANguest/R-release/shinyGizmo.Rcheck'
* using R version 4.2.2 (2022-10-31 ucrt)
* using platform: x86_64-w64-mingw32 (64-bit)
...
* checking CRAN incoming feasibility ... NOTE
Maintainer: 'Krystian Igras <krystian8207@gmail.com>'
...
Status: 1 NOTE
```

```
* using log directory 'd:/RCompile/CRANguest/R-devel/shinyGizmo.Rcheck'
* using R Under development (unstable) (2022-12-18 r83472 ucrt)
* using platform: x86_64-w64-mingw32 (64-bit)
...
* checking CRAN incoming feasibility ... [13s] NOTE
Maintainer: 'Krystian Igras <krystian8207@gmail.com>'
...
Status: 1 NOTE
```
