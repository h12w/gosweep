#!/bin/bash
#
# The script does automatic checking on a Go package and its sub-packages, including:
#
# 1. gofmt
# 2. goimports
# 3. golint
# 4. go vet
# 5. ineffassign
# 6. race detector
# 7. test coverage
#

set -e

go build $(go list ./... | grep -v '/vendor/')

echo 'mode: count' > profile.cov


for pkg in $(go list ./... | grep -v '/vendor/');
do
    dir="$GOPATH/src/$pkg"
    len="${#PWD}"
    dir_relative=".${dir:$len}"


    # 1. test
    echo "processing package $dir_relative ... (1/8)"
    go test -v -short -covermode=count -coverprofile="$dir_relative/profile.tmp" "$dir_relative"
    if [ -f "$dir_relative/profile.tmp" ]
    then
        cat "$dir_relative/profile.tmp" | tail -n +2 >> profile.cov
        rm "$dir_relative/profile.tmp"
    fi

    # 2. fmt
    echo "processing package $dir_relative ... (2/8)"
    gofmt -l -w "$dir"/*.go

    # 3. imports
    echo "processing package $dir_relative ... (3/8)"
    goimports -l -w "$dir"/*.go | tee /dev/stderr

    # 4. lint
    echo "processing package $dir_relative ... (4/8)"
    golint $pkg | tee /dev/stderr

    # 5. vet
    echo "processing package $dir_relative ... (5/8)"
    go vet $pkg | tee /dev/stderr

    # 6. ineffassign
    echo "processing package $dir_relative ... (6/8)"
    ineffassign -n $dir | tee /dev/stderr

    # 7. race conditions
    echo "processing package $dir_relative ... (7/8)"
    #env GORACE="halt_on_error=1" go test -short -race $pkg

    echo "processing package $dir_relative ... (8/8)"

done

# test coverage
echo 'processing code coverage...'
go tool cover -func profile.cov


# To submit the test coverage result to coveralls.io,
# use goveralls (https://github.com/mattn/goveralls)

if [ -n "${CI_SERVICE+1}" ]; then
    echo "goveralls with ${CI_SERVICE}"
    if [ -n "${COVERALLS_TOKEN+1}" ]; then
        goveralls -coverprofile=profile.cov -service=$CI_SERVICE -repotoken $COVERALLS_TOKEN
    else
        goveralls -coverprofile=profile.cov -service=$CI_SERVICE
    fi
fi
