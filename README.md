# Overleaf Local Backups

This repo serves the purpose of a local backup solution for existing overleaf projects "in the cloud", to avoid loss of information in the long run due to unforseen issues, eg overleaf.com going down (*which actually happened late in 2024*).

## Structure

The structure of this repo follows the project organization of my research group's main overleaf account,
where folders of the first level are named after the year (you can however create folders/tags with arbitrary names) the contained projects have been created in, starting with projects and drafts from 2014:
```
- 2014
    + NIPS 2014 DRAFT [...]
- 2015
    + [...]
- 2016
    + [...]
- <year>
    + <project title i>
    + <project title j>

```

Within those folders all backed up resource files from the overleaf projects are contained/replicated via this script.

On the same level as the folders named by overleaf project tag, ie `<year>` are the `README.md` you are currently reading,
the `autosync.sh` script doing all the work,
as well as folder `keymaps` containing files with lists of overleaf project IDs as well as human readable names in `CSV` format.
The files in `keymaps` are organized by year corresponding to the tag structure used for project organization of the of the my main overleaf account.
The optionally usable script `populate-readonly.sh` is called by `autosync.sh`, in case you want to push the backups to another repo, which I for example use as read-access repo for my group members, without exposing all the metadata gunk.

## How it all works

When running `autosync.sh`, the script will read a set of files from the `keymaps` folder. Note that this subset currently is specified to cover all project from the 2020s. See `autosync.sh:21`.

For each read `CSV` file from the `keymaps` folder, `autosync.sh` will
- download the respective projects from overleaf temporary location `_tmp`
- `rsync` the contents of `_tmp` to the backup target folder as identified by `<year>` as in the currently processed `csv` file name and the project's human readable project name as specified within the corresponding `csv` file's current line.
    + The use of `rsync` with the given parameters (see `autosync.sh:43`) will backup everything except the git sync files. This means backups are additive and nothing will be deleted, merely overwritten in case of file name conflicts. This means old files/figures which are not on overleaf anymore can be found in this repo.
- The temporary folder `_tmp` will be removed.
- The script then commits any changes made to the currenty backed up project (assuming this git project has been checked out via SSH, and the SSH pub key of the machine this is running is registered on the host git server).
- In the end, this script pushes its changes to its remote repo.

- Currently, in the final step, the script is pushing all the backed-up paper content to another "read only" repo I have prepared for the department, without the scripts, metadata, etc. If you wish to do the same, you just have to define the path to this locally cloned (initially empty) repo in `populate-readonly.sh` and the script will do the rest. If you do not want to do that, comment out `autosync.sh:73+`

**Currently the script is running daily at 03:00am o'clock as a cron job on one of my workstations, writing all the outputs into a daily log. This is the job config:**
```
# daily (nightly. 3am) overleaf backup sync
0 3 * * * cd <replace_with_local_path_to_this_repos_clone> && /usr/bin/bash autosync.sh > <replace_with_dir_where_you_want_to_keep_our_logs>/$(date +"\%Y-\%m-\%d").log 2>&1

```


## How can I make sure my papers are backed up
 - *Option 1:* Tell your overleaf account manager you want your project backed up. 
 - *Option 2:* You are / have access to the overleaf account holding all your papers and this very repo. Then open (or create) `keymaps/<year>.csv`, where `<year>` is the year of creation (and thus associated tag on overleaf) of the project.
    + Add a new line at the end of `keymaps/<year>.csv`, following the format `<overleaf_project_id>;<human_readable_name>`.
    + You can obtain the `overleaf_project_id` by opening the tex project via your overleaf account, and then copying the last segment of the URL in the browser's address bar (eg by double-clicking on it) which is given as `https://www.overleaf.com/project/<overleaf_project_id>`
    + You can obtain the `human_readable_name` by copying the project name (eg by double-clicking on it) from overleaf.
    + **Note** that `;` is used as a delimiter between project id and project name, and the script takes both parts left and right of `;` "as is", eg including all leading and trailing whitespaces. **Therefore ...**
    + **Take Care** to properly name your projects when entering them into the `csv` files, as this will determine the backup folder's name. Making changes to the project name in the csv at some later point will create another backup folder which will then need to be merged/cleaned manually.
    + Each `csv` file should end with an empty line, as it is common practice on unix/linux systems to ensure proper tool behavior.


For reference, below you can find how the current file `keymaps/DUMMY_3000.csv` looks like, with each line specifying a project to be backed up, with  the `overleaf_project_id` in the beginning, and separated with a `;` character from the `human_readable_name`, which in turn correspond to the backed up (fictional) projects in (fictional) folders `DUMMY_3000/<human_readable_name>` of this repo. Note the empty line in the end:

```
885bd0e3e76662c2cacf22c0;Fancy High Impact Research Paper
cc32cb0656682ae22ce80d7f;How To Write Project Proposals
269cde4d8d4762ae4c986ad2;Project LaTeX Deliverable Template

```







