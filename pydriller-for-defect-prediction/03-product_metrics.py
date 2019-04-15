from pydriller import GitRepository

repo = '/Users/luca/TUProjects/Salerno/jpacman-framework'

gr = GitRepository(repo)

last_commit = gr.get_head()
print('Commit: {} changed {} files.'.format(last_commit.hash, len(last_commit.modifications)))
for mod in last_commit.modifications:
    print('File: {} has {} additions and {} deletions'.format(mod.filename, mod.added, mod.removed))
    print('Complexity: {}. LOC {}'.format(mod.complexity, mod.nloc))

last_commit = gr.get_commit('51f041d')
print('Commit: {} changed {} files.'.format(last_commit.hash, len(last_commit.modifications)))
for mod in last_commit.modifications:
    print('File: {} has {} additions and {} deletions'.format(mod.filename, mod.added, mod.removed))
    print('Complexity: {}. LOC {}'.format(mod.complexity, mod.nloc))
