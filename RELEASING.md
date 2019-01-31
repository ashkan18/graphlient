# Releasing Graphlient

There're no hard rules about when to release graphlient. Release bug fixes frequently, features not so frequently and breaking API changes rarely.

### Release

Run tests, check that all tests succeed locally.

```
bundle install
rake
```

Check that the last build succeeded in [Travis CI](https://travis-ci.org/dblock/graphlient) for all supported platforms.

Change next release in [CHANGELOG.md](CHANGELOG.md) to the new version.

```
### 0.2.2 (7/10/2015)
```

Remove the line with "Your contribution here.", since there will be no more contributions to this release.

Update the version in `lib/graphlient/version.rb`.

Commit your changes.

```
git add CHANGELOG.md
git commit -m "Preparing for release, 0.2.2."
git push origin master
```

Release.

```
$ rake release

graphlient 0.2.2 built to pkg/graphlient-0.2.2.gem.
Tagged v0.2.2.
Pushed git commits and tags.
Pushed graphlient 0.2.2 to rubygems.org.
```

### Prepare for the Next Version

Add the next release to [CHANGELOG.md](CHANGELOG.md).

```
### 0.2.3 (Next)

* Your contribution here.
```

Increment the third version number in [lib/graphlient/version.rb](lib/graphlient/version.rb). Usually the major version is incremented during the development cycle when the release contains major features or breaking API changes (eg. change `0.2.1` to `0.3.0`).

Commit your changes.

```
git add CHANGELOG.md lib/graphlient/version.rb
git commit -m "Preparing for next development iteration, 0.2.3."
git push origin master
```
