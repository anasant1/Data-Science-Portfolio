The final project for my master's Machine Learning course from SPR 24 was a group assignment in which my team members and I selected a dataset to solve a business problem of our choosing.
We decided to work with the IBM Telco dataset found here: https://www.kaggle.com/datasets/yeanzc/telco-customer-churn-ibm-dataset to explore customer churn and test different algorithms' performance. We decided to apply CART via decision tree and random forest classification and regression models, as well as SVM classification and regression. 

My team members were Ryuya Sekido and Cole Thorpen, and our instructor was Dr. Ying Lin

## TABLE OF CONTENTS
1. Jupyter Notebook (Data processing, EDA, CART & SVM models): 
2. Findings report:
3. Findings presentation: 

## Summary of findings
In this specific dataset, the target classes were heavily imbalanced, which affected model performance across churn recall metrics. However, upon fine-tuning each model, we found the SVM classifier performed the best as it had the highest F1 score (or harmonic mean of precision and recall) of 0.67, whereas the other two models were .07 points behind. Since the business priority is to identify all churning customers to implement customer retention strategies, the SVM classifier performance promises better results. For the regressor model we aimed to assign a churn score to customers, and in this case, all 3 model types had similar performances, where even a tuned decision tree was in the prediciton error range of 20.5 points, while SVM had a prediction error range of 20.1 points (per MAE). In this case, we would recommend using a random forest but given that customer churn is a problem that requires cross-functional collaboration with non-technical stakeholders, prioritizing an explainable and more interpretable model would be preferred. In this case, selecting a simple decision tree may present less challenges in explanation due to the recursive binary splitting it employs, whereas SVM would be more challenging to explain. 
