#!/usr/bin/env python
# coding: utf-8

# # Assignment 4

# In[ ]:


# In[ ]:
import numpy as np

import keras
from keras.datasets.cifar10 import load_data
from keras.applications.vgg16 import preprocess_input, VGG16
from keras.applications.resnet import ResNet50
from keras.models import Sequential, Model
from keras.layers import Flatten
from keras.utils import to_categorical
from keras import backend as k

# In[ ]:


(x_train, y_train), (x_test, y_test) = load_data()

x_train = preprocess_input(x_train)
x_test = preprocess_input(x_test)

train_indices = np.where((y_train.ravel() >= 5) & (y_train.ravel() <= 9))
test_indices = np.where((y_test.ravel() >= 5) & (y_test.ravel() <= 9))

# # Extract Features using VGG

# In[ ]:


IMG_SHAPE = x_train[0].shape
model = Sequential()

VGG16_MODEL = VGG16(input_shape=IMG_SHAPE, include_top=False, weights='imagenet')
resnet50 = ResNet50(input_shape=IMG_SHAPE, include_top=False, weights='imagenet')
resnet50.summary()

resnet50_cut = Model(inputs=resnet50.inputs, output=resnet50.get_layer('conv5_block3_out').output)
resnet50_cut.compile('Adam', 'categorical_crossentropy')

model.add(VGG16_MODEL)
model.add(Flatten())
model.compile('Adam', 'categorical_crossentropy')

# In[]:
VGG16_MODEL.summary()

# In[ ]:

from matplotlib import pyplot as plt

img_tensor = x_train[0][np.newaxis, :, :, :]

layer_names = []
for layer in RESNET_MODEL.layers:
    layer_names.append(layer.name)  # Names of the layers, so you can have them as part of your plot

images_per_row = 16
from keract import get_activations
from keract import display_activations, display_heatmaps

activations = get_activations(resnet50_cut, img_tensor, 'conv5_block3_out')
activations['conv5_block3_out/Relu:0'] = activations['conv5_block3_out/Relu:0'][:, :, :, :6]
display_heatmaps(activations, img_tensor,  save=True)




# In[ ]:

x =

x_train_features = model.predict(x_train)
x_test_features = model.predict(x_test)

# In[ ]:


np.save('x_train.npy', x_train_features)  # save
np.save('x_test.npy', x_test_features)  # save

# In[ ]:


np.save('y_train.npy', to_categorical(y_train))  # save
np.save('y_test.npy', to_categorical(y_test))  # save

# # EXPS with features

# ## SVM

# In[ ]:


from sklearn.svm import LinearSVC

# In[ ]:


split = 0.8

x_data = np.load('dataset/vgg/block3_conv1/x_train.npy')
x_data = x_data[train_indices]

x_test = np.load('dataset/vgg/block3_conv1/x_test.npy')
x_test = x_test[test_indices]

y_data = np.load('dataset/vgg/block3_conv1/y_train.npy')
y_data = y_data[train_indices]

y_test = np.load('dataset/vgg/block3_conv1/y_test.npy')
y_test = y_test[test_indices]

splitat = int(len(x_data) * split)
x_train = x_data[:splitat]

y_train = y_data[:splitat]

x_val = x_data[splitat:]
y_val = y_data[splitat:]

y_test = np.argmax(y_test, axis=1)
y_val = np.argmax(y_val, axis=1)
y_train = np.argmax(y_train, axis=1)


mean = np.mean(x_train)
std = np.std(x_train)

x_train = (x_train - mean) / std
x_val = (x_val - mean) / std
x_test = (x_test - mean) / std

# In[]:
model = LinearSVC()

model.fit(x_train, y_train)

import pickle
with open('models/vgg/block3_conv1/svm.pickle', 'wb') as out:
    pickle.dump(model, out)



# In[]:

from sklearn.metrics import classification_report
with open('models/vgg/block3_conv1/svm.pickle', 'rb') as out:
    model = pickle.load(out)

predictions = model.predict(x_val)
test_predictions = model.predict(x_test)

# labels_val_from_categorical = np.argmax(labels_val, axis=1)
print(classification_report(y_val, predictions))
print(classification_report(y_test, test_predictions))






# ## Logistic Regressor

# In[ ]:


from sklearn.linear_model import LogisticRegressionCV

# In[ ]:


split = 0.8

x_data = np.load('dataset/vgg/block3_conv1/x_train.npy')
x_test = np.load('dataset/vgg/block3_conv1/x_test.npy')
y_data = np.load('dataset/vgg/block3_conv1/y_train.npy')
y_test = np.load('dataset/vgg/block3_conv1/y_test.npy')

splitat = int(len(x_data) * split)
x_train = x_data[:splitat]
y_train = y_data[:splitat]

x_val = x_data[splitat:]
y_val = y_data[splitat:]

y_test = np.argmax(y_test, axis=1)
y_val = np.argmax(y_val, axis=1)
y_train = np.argmax(y_train, axis=1)

# In[ ]:


model = LogisticRegressionCV(cv=5, multi_class='multinomial', max_iter=1000)

# In[66]:


model.fit(x_train, y_train)

# In[ ]:


predictions = model.predict(x_val)

# In[ ]:


import pickle

with open('models/logistic.pickle', 'wb') as out:
    pickle.dump(model, out)

# In[69]:


from sklearn.metrics import classification_report

# labels_val_from_categorical = np.argmax(labels_val, axis=1)
print(classification_report(y_val, predictions))

# ## Tree ensamble

# In[ ]:


from sklearn.ensemble import ExtraTreesClassifier

# In[ ]:


split = 0.8

x_data = np.load('dataset/x_train.npy')
x_test = np.load('dataset/x_test.npy')
y_data = np.load('dataset/y_train.npy')
y_test = np.load('dataset/y_test.npy')

splitat = int(len(x_data) * split)
x_train = x_data[:splitat]
y_train = y_data[:splitat]

x_val = x_data[splitat:]
y_val = y_data[splitat:]

y_test = np.argmax(y_test, axis=1)
y_val = np.argmax(y_val, axis=1)
y_train = np.argmax(y_train, axis=1)

# In[ ]:


model = ExtraTreesClassifier()

# In[66]:


model.fit(x_train, y_train)

# In[ ]:


predictions = model.predict(x_val)

# In[ ]:


import pickle

with open('models/tree_ensamble.pickle', 'wb') as out:
    pickle.dump(model, out)

# In[69]:


from sklearn.metrics import classification_report

# labels_val_from_categorical = np.argmax(labels_val, axis=1)
print(classification_report(y_val, predictions))

# ## XGBClassifier

# In[ ]:

import xgboost as xgb
from xgboost import XGBClassifier

# In[ ]:


split = 0.8

x_data = np.load('dataset/vgg/block3_conv1/x_train.npy')
x_data = x_data[train_indices]

x_test = np.load('dataset/vgg/block3_conv1/x_test.npy')
x_test = x_data[test_indices]

y_data = np.load('dataset/vgg/block3_conv1/y_train.npy')
y_data = y_data[train_indices]

y_test = np.load('dataset/vgg/block3_conv1/y_test.npy')
y_test = y_test[test_indices]

splitat = int(len(x_data) * split)
x_train = x_data[:splitat]

y_train = y_data[:splitat]

x_val = x_data[splitat:]
y_val = y_data[splitat:]

y_test = np.argmax(y_test, axis=1)
y_val = np.argmax(y_val, axis=1)
y_train = np.argmax(y_train, axis=1)


# In[ ]:
data_dmatrix = xgb.DMatrix(data=x_train, label=y_train)

params = {"objective": "multi:softmax", "num_class": 10, 'colsample_bytree': 0.3, 'learning_rate': 0.01,
          'max_depth': 5, 'alpha': 10}

model = xgb.XGBClassifier(dtrain=data_dmatrix, params=params, nfold=3, num_boost_round=50, early_stopping_rounds=10,
               metrics="mlogloss", seed=123)

# In[ ]:

model.fit(x_train, y_train)

predictions = model.predict(x_val)

# In[ ]:


import pickle

with open('models/xgboost.pickle', 'wb') as out:
    pickle.dump(model, out)

# In[69]:


from sklearn.metrics import classification_report

# labels_val_from_categorical = np.argmax(labels_val, axis=1)
print(classification_report(y_val, predictions))



# ## KNN

# In[ ]:


split = 0.8

x_data = np.load('dataset/vgg/block3_conv1/x_train.npy')
x_test = np.load('dataset/vgg/block3_conv1/x_test.npy')
y_data = np.load('dataset/vgg/block3_conv1/y_train.npy')
y_test = np.load('dataset/vgg/block3_conv1/y_test.npy')

splitat = int(len(x_data) * split)
x_train = x_data[:splitat]
y_train = y_data[:splitat]

x_val = x_data[splitat:]
y_val = y_data[splitat:]

# In[ ]:


from sklearn.neighbors import KNeighborsClassifier

neigh = KNeighborsClassifier(n_neighbors=3)
neigh.fit(x_train, y_train)

# In[ ]:


predictions = np.apply_along_axis(lambda x: neigh.predict([x]), axis=-1, arr=x_val)

# In[ ]:


from sklearn.metrics import classification_report

# labels_val_from_categorical = np.argmax(labels_val, axis=1)
y_preds = np.argmax(predictions, axis=-1)
y_sparse_val = np.argmax(y_val, axis=-1)
print(classification_report(y_sparse_val, y_preds))
