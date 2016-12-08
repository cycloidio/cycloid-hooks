# Cycloid-hooks
Gathering of hooks used at cycloid

# Content
[update_hook.sh](https://github.com/cycloidio/cycloid-hooks/blob/master/scripts/update_hook.sh): Used to make it easier to update hooks of git directories.

[commit-msg](https://github.com/cycloidio/cycloid-hooks/blob/master/client-side/commit-msg): Hook to encourage the formatting of git commit, following the style of [the linux repo](https://github.com/torvalds/linux/commits/master).

[pre-commit](https://github.com/cycloidio/cycloid-hooks/blob/master/client-side/pre-commit): A wrapper that is meant to call all pre-commit hooks located in pre-commit.d folder

[pre-commit-ansible-vault](https://github.com/cycloidio/cycloid-hooks/blob/master/client-side/pre-commit.d/pre-commit-ansible-vault): Used to check if any ansible vault file is being pushed without encryption

[pre-commit-gofmt](https://github.com/cycloidio/cycloid-hooks/blob/master/client-side/pre-commit.d/pre-commit-gofmt): Meant to check the formatting of go files before pushing them.

[pre-push](https://github.com/cycloidio/cycloid-hooks/blob/master/client-side/pre-push): Used as safety net to check if any ansible vault file has been localy commited before being pushed. Very similar to [pre-commit-ansible-vault](https://github.com/cycloidio/cycloid-hooks/blob/master/client-side/pre-commit.d/pre-commit-ansible-vault).

# How to use
If not already the case, create a template directory for git that you will use:
```bash
mkdir -p $HOME/.git_template/hooks/
```

(Again if not already the case) Update your gitconfig:
```bash
[init]
	templatedir = </home/.../.git_template>
```
Note: This is the full path, not including env variable!

Get the repository with the eventual branch that you want:
```bash
git clone https://github.com/cycloidio/cycloid-hooks/ $HOME/git/cycloid-hooks/
```

Then, the easiest could be to setup an alias based on the script in order to do the updates.

Example of alias - admitting your git repositorie(s) is(are) located in `$HOME/git/my-git-projects` directory:

```bash
alias update_hooks='rsync -arq $HOME/git/cycloid-hooks/client-side/ $HOME/.git_template/hooks/ && $HOME/git/cycloid-hooks/scripts/update_hook.sh -v -t $HOME/.git_template/hooks -r $HOME/git/my-git-projects'

# Now you can call it with
update_hooks
```

Usage of the script:
```bash
usage: update_hook.sh -r GIT_DIR -t TEMPLATE_HOOK_DIR [-v]

This script updates all hooks located in the TEMPLATE_HOOK_DIR of all repositories located under the GIT_DIR.
This allows to easily update hooks to use their latest version.

OPTIONS:
   -r       Directory containing all repositories
   -t       Template directory containing hooks
   -v       Verbose enablement
```

# License
The MIT License (MIT)

Copyright (c) 2016 cycloid.io

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
