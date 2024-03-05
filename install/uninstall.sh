ARGOCD_CR_NAMESPACE=openshift-gitops
ARGOCD_OPERATOR_NAMESPACE=openshift-operators
ARGOCD_TOOLING_NAMESPACE=tooling
oc delete application argocd-rbac -n ${ARGOCD_CR_NAMESPACE}
oc delete application devspaces-install -n ${ARGOCD_CR_NAMESPACE}
oc delete application namespace-config -n ${ARGOCD_CR_NAMESPACE}
oc delete application devspaces-parent-app -n ${ARGOCD_CR_NAMESPACE}
oc delete appproject rhtas-project -n ${ARGOCD_CR_NAMESPACE}
oc delete gitopsservice cluster -n ${ARGOCD_CR_NAMESPACE}
oc delete argocd openshift-gitops -n ${ARGOCD_CR_NAMESPACE}
oc delete csv openshift-gitops-operator.v1.9.1 -n ${ARGOCD_OPERATOR_NAMESPACE}
oc delete subs openshift-gitops-operator -n ${ARGOCD_OPERATOR_NAMESPACE}
oc delete project ${ARGOCD_CR_NAMESPACE}
oc delete project ${ARGOCD_TOOLING_NAMESPACE}
