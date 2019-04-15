from pydriller import RepositoryMining
from pydriller.domain.commit import ModificationType

repo = '/Users/luca/TUProjects/Salerno/jpacman-framework'
start = 'f3178b8'
stop = '51f041d'

files = {}
for commit in RepositoryMining(repo, from_commit=start, to_commit=stop).traverse_commits():
    for mod in commit.modifications:
        if mod.filename.endswith('.java') and mod.change_type is not ModificationType.DELETE:
            process_metrics = {'change': mod.change_type, 'added': mod.added, 'removed': mod.removed, 'loc': mod.nloc, 'comp': mod.complexity}

            path = mod.new_path
            if path not in files:
                files[path] = []
            files.get(path, []).append(process_metrics)

output = open('output.csv', 'w')
output.write('file,n-changes,added,removed,loc,complexity\n'.format())

for key, value in files.items():
    n_changes = len(value)
    last_added = value[n_changes - 1]['added']
    last_removed = value[n_changes - 1]['removed']
    last_loc = value[n_changes - 1]['loc']
    last_comp = value[n_changes - 1]['comp']
    print('Changes: {}. Added: {}. Removed: {}. LOC: {}. Comp.: {}. File: {}'.format(n_changes, last_added, last_removed, last_loc, last_comp, key))
    # Append process metrics to CSV file
    output.write('{},{},{},{},{},{}\n'.format(key, n_changes, last_added, last_removed, last_loc, last_comp))
