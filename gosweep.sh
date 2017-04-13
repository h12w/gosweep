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
# 8. gocyclo
# 9. misspell
#

set -e

go build $(go list ./... | grep -v '/vendor/')

echo 'mode: count' > profile.cov

complexity="${GOCYCLO_COMPLEXITY:-5}"
locale="${MISSPELL_LOCALE:-US}"
max_steps=12

for pkg in $(go list ./... | grep -v '/vendor/');
do
    dir="$GOPATH/src/$pkg"
    len="${#PWD}"
    dir_relative=".${dir:$len}"


    # 1. test
    echo "processing package $dir_relative... (1/$max_steps)"
    go test -v -short -covermode=count -coverprofile="$dir_relative/profile.tmp" "$dir_relative"
    if [ -f "$dir_relative/profile.tmp" ]
    then
        cat "$dir_relative/profile.tmp" | tail -n +2 >> profile.cov
        rm "$dir_relative/profile.tmp"
    fi

    # 2. fmt
    echo "processing package $dir_relative... (2/$max_steps)"
    gofmt -l -w "$dir"/*.go

    # 3. imports
    echo "processing package $dir_relative... (3/$max_steps)"
    goimports -l -w "$dir"/*.go | tee /dev/stderr

    # 4. lint
    echo "processing package $dir_relative... (4/$max_steps)"
    golint $pkg | tee /dev/stderr

    # 5. vet
    echo "processing package $dir_relative... (5/$max_steps)"
    go vet $pkg | tee /dev/stderr

    # 6. ineffassign
    echo "processing package $dir_relative... (6/$max_steps)"
    ineffassign -n $dir | tee /dev/stderr

    # 7. race conditions
    echo "processing package $dir_relative... (7/$max_steps)"
    #env GORACE="halt_on_error=1" go test -short -race $pkg

done

# 8. gocyclo
echo "processing package $dir_relative... (8/$max_steps)"
find . -type f -name '*.go' -not -path './vendor/*' | xargs -I {} -P 2 gocyclo -over $complexity {}

# 9. misspell over .go files
echo "processing package $dir_relative... (9/$max_steps)"
find . -type f -name '*.go' -not -path './vendor/*' | xargs -I {} -P 2 misspell -error -source go {}

# 10. misspell over .txt .md .rst files
echo "processing text files... (10/$max_steps)"
find . -type f -not -path './vendor/*' \( -name '*.md' -o -name '*.txt' -o -name '*.rst' \) | xargs -I {} misspell -error -source text {}

# 11. test coverage
echo "processing code coverage... (11/$max_steps)"
go tool cover -func profile.cov

# 12. goveralls
if [ -n "${CI_SERVICE+1}" ]; then
    echo "goveralls with ${CI_SERVICE}"
    if [ -n "${COVERALLS_TOKEN+1}" ]; then
        goveralls -coverprofile=profile.cov -service=$CI_SERVICE -repotoken $COVERALLS_TOKEN
    else
        goveralls -coverprofile=profile.cov -service=$CI_SERVICE
    fi
fi

echo "done. (12/$max_steps)"
