import numpy as np, matplotlib.pyplot as plt, pandas as pd

from collections import Counter
from sklearn.impute import SimpleImputer
from sklearn.model_selection import train_test_split
import imblearn
from sklearn.tree import DecisionTreeClassifier
from sklearn.model_selection import cross_val_score
from sklearn.metrics import confusion_matrix
from sklearn.metrics import classification_report
from sklearn.metrics import confusion_matrix

risk_factors = pd.read_csv('./kag_risk_factors_cervical_cancer.csv', header=0, na_values='?')
risk_factors.drop(risk_factors.columns[[14, 21, 26, 27]], axis=1, inplace=True)
# print(risk_factors.columns, risk_factors.shape)
values = risk_factors.values.astype('int64')
X = values[:, 0:31]
y = values[:, 31]

imputer = SimpleImputer(strategy='median')
X = imputer.fit_transform(X)

print('Amount of each class before under-sampling: {0}'.format(Counter(y)))
iht = imblearn.under_sampling.InstanceHardnessThreshold(random_state = 15)
X, y = iht.fit_sample(X, y)
print('Amount of each class after under-sampling: {0}'.format(Counter(y)))

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size = 0.25, random_state = 15)

print(X_train.shape, X_test.shape)

classifier = DecisionTreeClassifier(criterion='gini', max_leaf_nodes= None,
                                    min_samples_leaf=14, min_samples_split=2 ,
                                    random_state = 15)
classifier.fit(X_train, y_train)
y_pred = classifier.predict(X_test)

# print(classification_report(y_test, y_pred))

print(pd.DataFrame(
    confusion_matrix(y_test, y_pred),
    columns=['Predicted No', 'Predicted Yes'],
    index=['Actual No', 'Actual Yes']
))

scores = cross_val_score(classifier, X, y, scoring='f1_macro', cv=10)
print('Macro-F1 average: {0}'.format(scores.mean()))
