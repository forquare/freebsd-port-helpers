# gomod2portmk

This is a really, *really*, tacky script to parse the go.mod file of Golang projects that use the new  dependancy manager thingy, and output the correct format for a FreeBSD Ports Makefile.

I've specifically created it for [gohugoio/hugo](https://github.com/gohugoio/hugo), 
and so there are a few things that may break.

## Setup
```
cd <go_dir>/
export GOPATH=${PWD}
 
cd src/<code>
glide update && glide install
<...output...>
 
go install
cd ../../bin
```

## Usage
Either use `gomod2portmk` on a file:
```
./gomod2portmk /path/to/my/go.mod
```

Or use `gomod2portmk` from stdin:
```
curl -s https://example.com/somerepo/go.mod | ./gomod2portmk 
```
