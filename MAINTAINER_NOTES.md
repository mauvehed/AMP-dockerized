# Maintainer Notes

## Make the tag

### Lightweight Tag: A simple tag with no additional metadata.

```sh
git tag <tag-name>
```

Example:

```sh
git tag v1.0.0
```

### Annotated Tag: A tag with metadata like a message, author, and date.

```sh
git tag -a <tag-name> -m "Tag message"
```

Example:

```sh
git tag -a v1.0.0 -m "First stable release"
```

## Verify the Tag

Check the list of existing tags to confirm the new tag was created:

```sh
git tag
```

### Push the Tag to GitHub

To push a specific tag:

```sh
git push origin <tag-name>
```

Example:

```sh
git push origin v1.0.0
```

To push all tags:

```sh
git push --tags
```

### Verify the Tag on GitHub

Go to your repository on GitHub, navigate to the "Releases" or "Tags" section, and confirm that the tag is listed.
