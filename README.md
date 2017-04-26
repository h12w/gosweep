# GoSweep

This script performs the build, test and automatic checking of a Go package and its sub-packages using:

1. [gofmt][gofmt]
2. [goimports][goimports]
3. [golint][golint]
4. [go vet][go_vet]
5. [ineffassign][ineffassign]
6. [race detector][race_detector]
7. [test coverage][test_coverage] on package and its sub-packages, `/vendor` directories excluded
8. [goveralls][goveralls]
9. [gocyclo][gocyclo]
10. [misspell][misspell]

Migrated from my [Gist](https://gist.github.com/hailiang/0f22736320abe6be71ce).


## Dependencies

To setup all the dependencies need to run the script do:
```
$ go get -v github.com/client9/misspell/cmd/misspell
$ go get -v github.com/fzipp/gocyclo
$ go get -v github.com/h12w/gosweep
$ go get -v github.com/mattn/goveralls
$ go get -v github.com/Masterminds/glide
```


## Environment variables

- **GOCYCLO_COMPLEXITY**: maximum allowed function complexity threshold (default: `5`).
- **MISSPELL_LOCALE**: English locale (default: `US`).


## Continuous Integration

### travis-ci

Example of `.travis.yml` file for Go:

```yaml
language: go
cache:
  directories:
    - ${GOPATH}/src/github.com/${TRAVIS_REPO_SLUG}/vendor
    - ${GOPATH}/src/github.com/fzipp
    - ${GOPATH}/src/github.com/h12w
    - ${GOPATH}/src/github.com/Masterminds
    - ${GOPATH}/src/github.com/mattn
go:
  - tip
  - 1.8
  - 1.7
  - 1.6
sudo: false

env:
    CI_SERVICE=travis-ci

install:
  - go get -v github.com/client9/misspell/cmd/misspell
  - go get -v github.com/fzipp/gocyclo
  - go get -v github.com/h12w/gosweep
  - go get -v github.com/mattn/goveralls
  - go get -v github.com/Masterminds/glide
  - glide install

script:
  - bash ${GOPATH}/src/github.com/h12w/gosweep/gosweep.sh
```


[go_vet]:	http://golang.org/cmd/vet	"go vet"
[gocyclo]:  https://github.com/fzipp/gocyclo  "gocyclo"
[gofmt]:	http://golang.org/cmd/gofmt/	"gofmt"
[goimports]:	https://godoc.org/golang.org/x/tools/cmd/goimports	"golang.org/x/tools/cmd/goimports"
[golint]:	https://github.com/golang/lint	"golang/lint"
[goveralls]:	https://github.com/mattn/goveralls	"mattn/goveralls"
[ineffassign]: https://github.com/gordonklaus/ineffassign "ineffassign"
[misspell]: https://github.com/client9/misspell "misspell"
[race_detector]:	http://blog.golang.org/race-detector	"race detector"
[test_coverage]:	http://blog.golang.org/cover	"test coverage"
