import os


APP_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.dirname(APP_DIR)


def app_path(*parts):
    return os.path.join(APP_DIR, *parts)


def repo_path(*parts):
    return os.path.join(REPO_ROOT, *parts)
