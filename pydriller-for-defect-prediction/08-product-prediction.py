from pydriller import RepositoryMining, GitRepository
from pydriller.domain.commit import ModificationType

repo = '/Users/luca/TUProjects/Salerno/jpacman-framework'


def get_buggy_commits():
    fix_commits = []
    for commit in RepositoryMining(repo).traverse_commits():
        if 'fix' in commit.msg:
            fix_commits.append(commit)

    gr = GitRepository(repo)

    buggy_commit_hashs = set()
    for fix_commit in fix_commits:
        bug_commits = gr.get_commits_last_modified_lines(fix_commit)
        buggy_commit_hashs.update(bug_commits)  # Add a set to a set
    return buggy_commit_hashs


def print_metrics_per_file(files):
    output = open('output.csv', 'w')
    output.write('file,n-changes,added,removed,loc,complexity,buggy\n'.format())

    for key, value in files.items():
        n_changes = len(value)
        added = value[n_changes - 1]['added']
        removed = value[n_changes - 1]['removed']
        loc = value[n_changes - 1]['loc']
        comp = value[n_changes - 1]['comp']
        buggy = value[n_changes - 1]['buggy']
        # Append process metrics to CSV file
        output.write('{},{},{},{},{},{},{}\n'.format(key, n_changes, added, removed, loc, comp, buggy))


def calculate_metrics(bugs):
    files = {}
    for commit in RepositoryMining(repo).traverse_commits():
        for mod in commit.modifications:
            if mod.filename.endswith('.java') and mod.change_type is not ModificationType.DELETE:
                buggy = True if commit.hash in bugs else False
                process_metrics = {'change': mod.change_type, 'added': mod.added, 'removed': mod.removed, 'loc': mod.nloc, 'comp': mod.complexity, 'buggy': buggy}
                path = mod.new_path
                if path not in files:
                    files[path] = []
                files.get(path, []).append(process_metrics)
    return files


# Main
buggy_commit = get_buggy_commits()
print('{} buggy commits'.format(len(buggy_commit)))

files = calculate_metrics(buggy_commit)
print_metrics_per_file(files)
