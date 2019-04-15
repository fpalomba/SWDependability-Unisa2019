from pydriller import RepositoryMining
from pydriller.domain.commit import ModificationType

repo = '/Users/luca/TUProjects/Salerno/jpacman-framework'
start = 'f3178b8'
stop = '51f041d'

files = {}
for commit in RepositoryMining(repo, from_commit=start, to_commit=stop).traverse_commits():
    for mod in commit.modifications:
        if mod.filename.endswith('.java') and mod.change_type is not ModificationType.DELETE:
            path = mod.new_path
            if path not in files:
                files[path] = []
            files.get(path, []).append(mod.change_type)

for file in files:
    print('Name: {}. Changes: {}'.format(file, len(files[file])))
