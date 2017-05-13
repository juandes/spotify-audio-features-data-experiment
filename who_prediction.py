import pandas as pd
from sklearn.linear_model import SGDClassifier
from sklearn.model_selection import GridSearchCV
from sklearn import metrics


def who_prediction():
    df = pd.read_csv('implicit_features.csv')
    # data is a data frame consisting of the predictors (columns 1 to 7)
    data = df[df.columns[:7]]
    labels = df.who

    parameters = {
        'alpha': (0.001, 0.0001, 0.00001, 0.000001),
        'penalty': ('l2', 'elasticnet',),
        'n_iter': (10, 50, 100),
        'loss': ('log',)
    }

    # Perform a grid search with cross validation to search for the best parameters.
    grid_search = GridSearchCV(SGDClassifier(), parameters, n_jobs=-1,
                               verbose=1, cv=5, scoring='accuracy')
    grid_search.fit(data, labels)
    print "Best score: {}".format(grid_search.best_score_)
    print "Best parameters: {}".format(grid_search.cv_results_['params'][grid_search.best_index_])
    # pd.DataFrame(grid_search.cv_results_)
    # grid_search.best_estimator_.coef_

    # features order: energy, liveness, speechiness, acousticness, instrumentalness
    # danceability, and valence
    # A Better Beginning (Mass Effect Andromeda OST), Spotify track ID: 4dU7fHmu3y9CrOTotmjkgf
    print grid_search.predict([[0.266, 0.0944, 0.0380, 0.579, 0.923, 0.248, 0.0483]])
    # Love On The Brain (Rihanna)
    print grid_search.predict([[0.637, 0.0789, 0.0471, 0.0717, 0.0000108, 0.509, 0.385]])


def main():
    who_prediction()

if __name__ == "__main__":
    main()
