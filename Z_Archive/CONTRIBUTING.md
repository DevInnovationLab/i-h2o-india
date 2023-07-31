# CONTRIBUTING

- [Folder structure](https://github.com/DevInnovationLab/dil-template-repo/edit/contributing/CONTRIBUTING.md#folder-structure)
- [Naming conventions](https://github.com/DevInnovationLab/dil-template-repo/edit/contributing/CONTRIBUTING.md#naming-conventions)
- [Setting up the project on a new computer](https://github.com/DevInnovationLab/dil-template-repo/edit/contributing/CONTRIBUTING.md#setting-up-the-project-on-a-new-computer)
- [Workflow](https://github.com/DevInnovationLab/dil-template-repo/blob/main/CONTRIBUTING.md#workflow)

## Folder structure

> INSTRUCTIONS: This template includes a suggested folder structure for your project. The readme files in each folder indicate how they should be used. If the suggested folder structure does not fit your use case, however, there is no problem in adapting it. The best folder structure is the one that works for your team. Just make sure to include a description of how your repository is organized in this section.

## Naming conventions

> INSTRUCTIONS: Describe naming conventions for each type of name

### Folders

### Files

- Code
- Data
- Documentation

### Variables

### Functions

## Setting up the project on a new computer

> INSTRUCTIONS: add link to project box folder on the next line
- [ ] If you don't have the Box client installed, install it and sync the [project's Box folder](link to project box folder)
- [ ] If you don't have a local git client installed, install one ([GitHub Desktop](https://desktop.github.com/) is a good option for beginners)
- [ ] Clone this repository: click on the green *Code* button, then *Open with GitHub Desktop* 
- [ ] Using the GitHub client, [check out the `develop` branch](https://docs.github.com/en/desktop/contributing-and-collaborating-using-github-desktop/making-changes-in-a-branch/managing-branches#switching-between-branches)
- [ ] Navigate to the local copy of the repository 
- [ ] *If the project uses Stata*, add your computer's username and file paths to `main.do` and commit your changes
- [ ] *If the project uses R*, create a new file called .Rprofile in the repository's root folder. This file should contain two lines of code, one activating your R environment and one defining the path to your Box folder. You can use the code below to create it by adjusting the second line to match your computer's installation of the Box client. Note that this file should be called just `.Rprofile`, without any additional file format indicated in its name (such as `.Rprofile.txt`).
```
source("renv/activate.R")
Sys.setenv(BOX = "C:/Users/YourUsername/Box")
```
- [ ] Change the options in the main script in order to re-run the whole code for the paper, from importing the raw data to recreating any intermediate and final datasets, to exporting any results
- [ ] Delete any code outputs in the GitHub repository, including meta data for all derived data sets, all tables, and all figures exported by the code
- [ ] Run the main script
- [ ] Check that:
  - [ ] The code ran, that is, there was no error message
  - [ ] All code outputs were recreated. If any file was not recreated, it will show as red on the git client.
  - [ ] There are no changes in the outputs or you can tell where they are coming from. If there are changes, commit the changes and explain in the commit message where the changes are coming from

**You are all set!**

## Workflow

> INSTRUCTIONS: describe the project's implementation of [gitflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) here. Below is an example

### What branch should I work on?

**Code should be developed on feature branches and merged to `develop` around twice a month.** Break large tasks into smaller tasks, taking one to two weeks of work, and work on them one at a time, with a different feature breanch for each. Once the task in a feature branch is complete, open a pull request to `develop`.

The `main` branch in this repository is protected. All changes to the main branch should come from *pull requests* (PR) from the `develop` branch. **The `develop` branch should be merged to master after (1) completing the data processing for a new data source; (2) developing a new piece of analysis; completing a round of code review.** 

### Opening a pull request from a feature branch to `develop`

- [ ] On the feature branch, run the entire project code from the main script. Make sure that the code is running and check whether any results are changing. 
 - *If there are any computationally intensive steps that were not edited*, you may skip them
 - *If there are any random process in your code*, run the code at least twice to make sure results are stable.
- [ ] Still on the feature branch, update the README file to include any new files or folders created.
- [ ] Commit and push your changes.
- [ ] Open a *pull request* (PR) from the feature branch to `develop`. Link to all the *issues* addressed in this PR on the PR message
- [ ] Assign a reviewer and let the reviewer know on Slack that they have been assigned a new PR. 
 - Team members who can review pull requests to `develop`: *List handles here*

### Opening a pull request from `develop` to `main`

- [ ] On the `develop` branch, run the entire project code from the main script. Make sure that the code is running and check whether any results are changing. 
	- [ ] Check that the code is running, that is, there was no error message and all scripts were executed.
	- [ ] Check that all outputs were recreated (looking at the date they were last modified).
    - [ ] Check whether there are changes in the outputs. If there are, make sure you understand where they are coming from and explain the reason in the commit message.
	- [ ] *If there are any random process in your code*, do this at least twice, committing changes between runs, to ensure the outputs are stable.
- [ ] Still on `develop`, make sure the README is up to date and includes all files and folders in the project.
- [ ] Commit and push your changes.
- [ ] Open a *pull request* (PR) from `develop` to `main`. Link to all the *issues* addressed in this PR on the PR message by copying them from feature branch PRs.
- [ ] Assign a reviewer and let the reviewer know on Slack that they have been assigned a new PR. 
 - Team members who can review pull requests to `main`: *List handles here*

### Reviewing a pull request

If you were assigned to review a pull request, do the following:
- [ ] Pull the changes to your local copy of the repository.
- [ ] Checkout the pull request as a branch.
- [ ] Run the whole code for the paper, from importing the raw data to recreating any intermediate and final datasets, to exporting any results.
	- [ ] Check that the code is running, that is, there was no error message and all scripts were executed.
    - [ ] Check whether there are changes in the outputs. If there are, make sure you understand where they are coming from and explain the reason in the commit message.
- [ ] Open the pull request on the browser and navigate to "Files changed", and [review the changes](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/reviewing-changes-in-pull-requests/about-pull-request-reviews).
- [ ] Once you are done, scroll to the top of the pr page and click on the "Review" button and approve the pull request or request additional changes.
  - [ ] If you requested additional changes, inform the team members who need to make them on Slack.
- [ ] Once the pull request is approved, merge it.
  - [ ] *If you just merged a pull request from a feature branch to `develop`*, delete the feature branch.
  - [ ] *If you just merged a pull request `develop` to `main`*, [create a release](https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository) from the `main` branch so you can easily navigate back to this stage of the project.
