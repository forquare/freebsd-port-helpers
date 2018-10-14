package main

import (
	"fmt"
	"flag"
	"bytes"
	"strings"
	"regexp"
	"io"
	"os"
	"encoding/json"
)

type Project struct {
	Mod	Module	`json:"Module"`
	Req	[]Require `json:"Require"`
	Ex	[]Require `json:"Exclude"`
	Rep	[]Replace `json:"Replace"`
}

type Module struct {
	Path	string `json:"Path"`
}

type Require struct {
	Path	string `json:"Path"`
	Version	string `json:"Version"`
	Indirect	bool `json:"Indirect"`
}

type Replace struct {
	Old	Require `json:"Old"`
	New	Require `json:"New"`
}

func main() {
	flag.Usage = func() {
		fmt.Println(`Reads go.mod file from either stdin or as an argument`)
	}
	flag.Parse()

	var data []byte

	// Read from stdin
	if flag.NArg() == 0 {
		data = readData(os.Stdin)
	} else {
		// Read from args
		if len(os.Args[:1]) < 1 {
			fmt.Fprintln(os.Stderr, "No file given")
			os.Exit(1)
		}
		if _, err := os.Stat(os.Args[1]); os.IsNotExist(err) {
			fmt.Fprintln(os.Stderr, "File not found")
			os.Exit(2)
		}
		file, err := os.Open(os.Args[1])
		if err != nil {
			panic(err)
		}

		data = readData(file)
	}

	project := Project{}
	err := json.Unmarshal(data, &project)
	if err != nil {
		panic(err)
	}

	required := pullDetails(project.Req)
	excluded := pullDetails(project.Ex)

	// Remove excluded entried from required ones
	for _, exclude := range excluded {
		for i, require := range required {
			if strings.Contains(require, exclude) {
				required = append(required[:i], required[i+1:]...)
			}
		}
	}

	// Replace any defined replacements
	for _, item := range project.Rep {
		var toReplace []Require
		toReplace = append(toReplace, item.Old)
		toReplace = append(toReplace, item.New)

		processed := pullDetails(toReplace)
		oldItem := processed[0]
		newItem := processed[1]

		oldItem = strings.Split(oldItem, "XXXXXXX")[0]
		replaceMatch := regexp.MustCompile("^" + oldItem)

		for i, require := range required {
			if replaceMatch.MatchString(require) {
				required[i] = newItem
			}
		}
	}

	for i, item := range required {
		if i == (len(required)-1) {
			fmt.Printf("%s\n", item)
		} else {
			fmt.Printf("%s \\\n", item)
		}
	}
}

func pullDetails(req []Require) ([]string) {
	var makefileline []string
	hashregex := regexp.MustCompile("^[vV][[:digit:].]*-[[:digit:]]{14}-[[:alnum:]]{12}")
	versionregex := regexp.MustCompile("^[vV][[:digit:].]*$")
	for _, requirement := range req {
		name := requirement.Path
		revision := "XXXXXXX"

		if strings.Contains(requirement.Version, "+incompatible") {
			// String "+incompatible" from tag name
			revision = strings.Split(requirement.Version, "+incompatible")[0]
		} else if hashregex.MatchString(requirement.Version) {
			// Grab git commit hash
			revision = strings.Split(requirement.Version, "-")[2]
		} else if versionregex.MatchString(requirement.Version) {
			// Matches a version number
			revision = requirement.Version
		} else if len(requirement.Version) == 0 {
			// This handles 'oldItem' cases where no version is defined
			revision = revision
		} else {
			fmt.Println("-- MANUALLY DO", name, "--")
		}

		splitted := strings.Split(name, "/")

		site := splitted[0]
		account := splitted[1]
		repo := ""

		if strings.Contains(site, "golang.org") {
			account = "golang"
		}

		if strings.Contains(site, "gopkg.in") {
			if strings.Contains(account, "yaml.v2"){
				account = "go-yaml"
				repo = "yaml"
			} else if strings.Contains(account, "check.v1"){
				account = "go-check"
				repo = "check"
			} else {
				fmt.Println("-- MANUALLY DO", name, "--")
			}
		}

		if repo == "" {
			repo = splitted[2]
		}

		if repo == "jwalterweatherman" {
			repo = "jWalterWeatherman"
		}

		repo2 := repo

		if strings.Contains(repo2, "-") {
			repo2 = strings.Replace(repo2, "-", "_", -1)
		}

		l := fmt.Sprintf("\t\t%s:%s:%s:%s/src/%s", account, repo, revision, repo2, name)
		makefileline = append(makefileline, l)

	}
	return makefileline

}

func readData(d io.Reader) ([]byte) {
	buf := &bytes.Buffer{}
	_, err := buf.ReadFrom(d)
	if err != nil {
		panic(err)
	}

	return buf.Bytes()
}


/*
Required output:
account:repo:commit:repo(use underscore)/src/sitename/account/repo
*/
