import gym
import tensorflow as tf
from tensorflow import keras
import numpy as np

env = gym.make('CartPole-v1')
obs = env.reset()
print(obs)
optimizer = keras.optimizers.Adam()

model = keras.models.Sequential()
model.add(keras.layers.Dense(5, input_shape=(4,), activation='relu'))
model.add(keras.layers.Dense(1, activation='sigmoid'))


def play_step(env, obs, model):
    loss_fn = keras.losses.binary_crossentropy
    with tf.GradientTape() as tape:
        l_prob = model(obs[np.newaxis])
        action = (tf.random.uniform([1, 1]) > l_prob)
        y_target = tf.constant([[1.]]) - tf.cast(action, tf.float32)
        loss = loss_fn(y_target, l_prob)
    grads = tape.gradient(loss, model.trainable_variables)
    obs, reward, done, info = env.step(int(action[0, 0].numpy()))
    return obs, reward, done, grads


print(play_step(env, obs, model))

env.close()
