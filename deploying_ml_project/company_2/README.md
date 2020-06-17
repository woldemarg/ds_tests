1. Building a pipe - highly inspired by [this post](http://jakevdp.github.io/blog/2014/06/10/is-seattle-really-seeing-an-uptick-in-cycling/)
notes:
* see [task desription](https://github.com/woldemarg/ds_tests/tree/master/machine_learning/company_2/task_description)
* see [alternative solutions](https://github.com/woldemarg/ds_tests/tree/master/machine_learning/company_2)
2. Deploying a pipe using Docker - according with [this tutorial](https://towardsdatascience.com/deploy-a-machine-learning-model-as-an-api-on-aws-43e92d08d05b)
3. Pipe API documentation - [pipeapi-env.eba-mnfm2dcm.eu-west-2.elasticbeanstalk.com](http://pipeapi-env.eba-mnfm2dcm.eu-west-2.elasticbeanstalk.com/)
3. Request example:\
curl -X GET *"pipeapi-env.eba-mnfm2dcm.eu-west-2.elasticbeanstalk.com/api"* -H "Content-Type:application/json" --data "{\"from\": \"2019-01-01\", \"to\": \"2019-01-07\"}"\
4. Response example:\
&nbsp;{\
&nbsp;&nbsp;"jalan":{\
&nbsp;&nbsp;&nbsp;"predictions":{\
&nbsp;&nbsp;&nbsp;&nbsp;"2019-01-01":0.0,\
&nbsp;&nbsp;&nbsp;&nbsp;"2019-01-02":0.0,\
&nbsp;&nbsp;&nbsp;&nbsp;"2019-01-03":0.0,\
&nbsp;&nbsp;&nbsp;&nbsp;"2019-01-04":1.0,\
&nbsp;&nbsp;&nbsp;&nbsp;"2019-01-05":1.0,\
&nbsp;&nbsp;&nbsp;&nbsp;"2019-01-06":0.0,\
&nbsp;&nbsp;&nbsp;&nbsp;"2019-01-07":0.0\
&nbsp;&nbsp;&nbsp;&nbsp;}\
&nbsp;&nbsp;&nbsp;},\
&nbsp;&nbsp;"rakuten":{\
&nbsp;&nbsp;&nbsp;"predictions":{\
&nbsp;&nbsp;&nbsp;&nbsp;"2019-01-01":2.0,\
&nbsp;&nbsp;&nbsp;&nbsp;"2019-01-02":2.0,\
&nbsp;&nbsp;&nbsp;&nbsp;"2019-01-03":2.0,\
&nbsp;&nbsp;&nbsp;&nbsp;"2019-01-04":3.0,\
&nbsp;&nbsp;&nbsp;&nbsp;"2019-01-05":3.0,\
&nbsp;&nbsp;&nbsp;&nbsp;"2019-01-06":2.0,\
&nbsp;&nbsp;&nbsp;&nbsp;"2019-01-07":2.0\
&nbsp;&nbsp;&nbsp;&nbsp;}\
&nbsp;&nbsp;&nbsp;}\
&nbsp;}
