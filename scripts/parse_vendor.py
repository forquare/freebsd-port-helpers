#!/usr/bin/env python2.7

import sys
import os
import json

def f5(seq, idfun=None):
   # order preserving
   if idfun is None:
       def idfun(x): return x
   seen = {}
   result = []
   for item in seq:
       marker = idfun(item)
       # in old Python versions:
       # if seen.has_key(marker)
       # but in new ones:
       if marker in seen: continue
       seen[marker] = 1
       result.append(item)
   return result


if os.path.isfile(sys.argv[1]):
    vendor = sys.argv[1]
else:
    print 'File not found...'
    exit(1)

results = []

with open(vendor) as data:
    d = json.load(data)

    for package in d['package']:
        account = None
        commit = package['revision'][:7]
        repo = None
        url = package['path']
        time = package['revisionTime']

        if 'github' in url.split('/')[0]:
            account = url.split('/')[1]
            repo = url.split('/')[2]
            url = '/'.join(url.split('/')[:3])
            if 'origin' in package:
                if 'vendor/github.com' in package['origin']:
                    print 'WARNING: Nested package'
                    print 'URL: %s'%url
                    print 'Origin: %s'%package['origin']
                    print 'Commit: %s'%commit
                    print ''
                    continue

        elif 'golang' in url.split('/')[0]:
            account = 'golang'
            repo = url.split('/')[2]
            url = '/'.join(url.split('/')[:3])

        elif 'gopkg' in url.split('/')[0]:
            if 'yaml.v2' not in url.split('/')[1]:
                print 'WARNING: Unexpected package in gopkg'
                print 'EXITING...'
                exit(2)
            else:
                account = 'go-yaml'
                repo = 'yaml'
                repo2 = 'yaml'
                results.append({'account': account, 
                                'commit': commit,
                                'repo': repo,
                                'repo2': repo2,
                                'path': url,
                                'revisionTime': time})
                continue

        if '-' in repo:
            repo2 = repo.replace('-', '_')
        else:
            repo2 = repo

        
        skip_this = False
        for p in results:
            if repo == p['path'].split('/')[2]:
                if time > p['revisionTime']:
                    results.remove(p)
                elif time < p['revisionTime']:
                    skip_this = True
                    break
                elif time == p['revisionTime']:
                    skip_this = True
                    break
                else:
                    continue
            else:
                continue

        if skip_this:
            continue

        results.append({'account': account, 
                        'commit': commit,
                        'repo': repo,
                        'repo2': repo2,
                        'path': url,
                        'revisionTime': time})
        

for package in results:
    print '%s:%s:%s:%s/src/%s \\' % (package['account'],
                                    package['repo'],
                                    package['commit'],
                                    package['repo2'],
                                    package['path'])

#result = '%s:%s:%s:%s/src/%s \\' % (account, repo, commit, repo2, url)
#results.append(result)

