import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
from sklearn.impute import SimpleImputer
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import OneHotEncoder
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler

# print(r'C:\pasta\pasta2\arquivo.txt')

dataset = pd.read_csv(r'04_dados_paises.csv')#r: raw

features = dataset.iloc[:, :-1].values  # o uso da virgula é para separar linha de coluna || usar :-1 voce pega o intervalo de 0 a -1 (excluindo o ultimo valor)

classe = dataset.iloc[:, -1].values # aqui voce pega exatamete o ultimo valor 

imputer = SimpleImputer( 
  missing_values=np.nan,     # substituir os valores que estao em NaN
  strategy="mean"    # dizendo como funciona a substituição do valor (mean = Média)
)

imputer.fit(features[:, 1:3])
features[:, 1:3] = imputer.transform(features[:, 1:3])    # o 0 é por que estamos operando na primeira coluna (country)


columnTransformer = ColumnTransformer(
  transformers=[('encoder', OneHotEncoder(), [0])],
  remainder="passthrough"
)
features = np.array(columnTransformer.fit_transform(features)) # array para transformar em vetor e a Feature deixa de apontar pra o inicio 

print(features)

labelEncoder = LabelEncoder()
classe = labelEncoder.fit_transform(classe)
print(classe)

features_treinamento, features_teste, classe_treinamento, classe_teste = train_test_split(features, classe, test_size=0.2, random_state=1)
# teste_size=0.2 || quanto maior o tamanho do teste, melhor 
# random_state=1 || serve para que toda vez que rodarmos, ser as mesmas bases (features_treinamento, features_teste..... || é possivel colocar RANDON no lugar do '1' e ter bases diferentes a cada rodada)


standardScaler = StandardScaler()

features_treinamento[:, 3:] = standardScaler.fit_transform(features_treinamento[:, 3:])

features_teste[:, 3:] = standardScaler.transform(features_teste[:, 3:])







