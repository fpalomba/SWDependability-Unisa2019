from pydriller import RepositoryMining

repo = 'https://github.com/SERG-Delft/jpacman-framework.git'

for commit in RepositoryMining(repo).traverse_commits():
    print(commit.hash)
