from pydriller import RepositoryMining, GitRepository

repo = '/Users/luca/TUProjects/Salerno/jpacman-framework'

fix_commits = []
for commit in RepositoryMining(repo, only_modifications_with_file_types=['.java']).traverse_commits():
    if 'fix' in commit.msg:
        fix_commits.append(commit)

gr = GitRepository(repo)

buggy_commit_hashs = set()
for fix_commit in fix_commits:
    bug_commits = gr.get_commits_last_modified_lines(fix_commit)
    buggy_commit_hashs.update(bug_commits)  # Add a set to a set

print('Number of commits with fixes: {}'.format(len(fix_commits)))
print('Number of commits with bugs: {}'.format(len(buggy_commit_hashs)))
