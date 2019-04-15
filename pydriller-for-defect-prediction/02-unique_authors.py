from pydriller import RepositoryMining

repo = '/Users/luca/TUProjects/Salerno/jpacman-framework'

authors = []
for commit in RepositoryMining(repo).traverse_commits():
    authors.append(commit.author.email)

unique_authors = set(authors)
print('Number of unique authors: {}'.format(len(unique_authors)))
print(unique_authors)