seal() {
  echo -n $1 | kubeseal --scope=$KUBESEAL_SCOPE --raw --from-file=/dev/stdin --cert=$KUBESEAL_CERT
}
sealnc() {
  echo -n $1 | kubeseal --scope=$KUBESEAL_SCOPE --raw --from-file=/dev/stdin --controller-name=sealed-secrets-controller --controller-namespace=sealed-secrets
}
kgp() {
  if [ $2 ]; then
    a=$(kubectl get pods -o json -A | jq -r '.items[] | select((.metadata.name | test("'$1'")) or (.metadata.labels? | select(type == "object") | to_entries | any(.value | test("'$1'")))) | select((.metadata.name | test("'$2'")) or (.metadata.labels[] | test("'$2'"))) | "\(.metadata.namespace) \(.metadata.name)"')
  else
    a=$(kubectl get pods -o json -A | jq -r '.items[] | select((.metadata.name | test("'$1'")) or (.metadata.labels? | select(type == "object") | to_entries | any(.value | test("'$1'")))) | "\(.metadata.namespace) \(.metadata.name)"')
  fi
  echo $a | awk '{ print length($0) " " $0; }' | sort -n | cut -d " " -f 2- | grep -m 1 .
}
kgpa() {
  if [ $2 ]; then
    echo $(kubectl get pods -o json -A | jq -r '.items[] | select(.metadata.namespace | test(".*'$1'.*")) | select((.metadata.name | test(".*'$2'.*")) or (.metadata.labels[] | test(".*'$2'.*"))) | ""')
  else
    echo $(kubectl get pods -o json -A | jq -r '.items[] | select((.metadata.name | test(".*'$1'.*")) or (.metadata.labels[] | test(".*'$1'.*"))) | "\(.metadata.namespace) \(.metadata.name)"')
  fi
}
#logspods() {
#  if [ $2 ]; then
#    a=$(kubectl get pods -o json -A | jq -r '.items[] | select(.metadata.namespace | test(".*'$1'.*")) | select((.metadata.name | test(".*'$2'.*")) or (.metadata.labels[] | test(".*'$2'.*"))) | .metadata.labels | add')
#  else
#    a=$(kubectl get pods -o json -A | jq -r '.items[] | select((.metadata.name | test(".*'$1'.*")) or (.metadata.labels[] | test(".*'$1'.*"))) | .metadata.labels | add')
#  fi
#  echo $a | awk '{ print length($0) " " $0; }' $file | sort -n | cut -d " " -f 2- | grep -m 1 .
#}
fak() {
  if [ $3 ]; then
    pod=($(kgp $2 $3))
  else
    pod=($(kgp $2))
  fi
  case "$1" in
  ex)
    echo "kubectl exec --stdin --tty -n "${pod[1]}" "${pod[2]}" -- bash"
    kubectl exec --stdin --tty -n ${pod[1]} ${pod[2]} -- bash
    ;;
  exsh)
    echo "kubectl exec --stdin --tty -n "${pod[1]}" "${pod[2]}" -- sh"
    kubectl exec --stdin --tty -n ${pod[1]} ${pod[2]} -- sh
    ;;
  sniff)
    if [ $5 ]; then
      echo "kubectl sniff -p --socket /run/k3s/containerd/containerd.sock -n "${pod[1]}" "${pod[2]}" "$4" "$5""
      kubectl sniff -p --socket /run/k3s/containerd/containerd.sock -n ${pod[1]} ${pod[2]} $4 $5
    else
      echo "kubectl sniff -p --socket /run/k3s/containerd/containerd.sock -n "${pod[1]}" "${pod[2]}""
      kubectl sniff -p --socket /run/k3s/containerd/containerd.sock -n ${pod[1]} ${pod[2]}
    fi
    ;;
  nsenter)
    echo "kubectl get pod -n "${pod[1]}" "${pod[2]}" -o yaml | yq '.status.containerStatuses[0].containerID' | sed -r 's/containerd:\/\/(.*)/\1/g'"
    cid=($(kubectl get pod -n "${pod[1]}" "${pod[2]}" -o yaml | yq '.status.containerStatuses[0].containerID' | sed -r 's/containerd:\/\/(.*)/\1/g'))
    echo "kubectl get pod -n "${pod[1]}" "${pod[2]}" -o yaml | yq '.spec.nodeName'"
    node=$(kubectl get pod -n "${pod[1]}" "${pod[2]}" -o yaml | yq '.spec.nodeName')
    echo "echo \$(ssh $node \"sudo CRI_CONFIG_FILE=/var/lib/rancher/rke2/agent/etc/crictl.yaml /var/lib/rancher/rke2/bin/crictl inspect -o yaml $cid\") | yq '.info.pid'"
    all=$(ssh $node "sudo CRI_CONFIG_FILE=/var/lib/rancher/rke2/agent/etc/crictl.yaml /var/lib/rancher/rke2/bin/crictl inspect -o yaml $cid")
    # echo $all
    # yq avoids issues with newlines and json quoting weirdness / invalid json output from crictl
    # https://github.com/kubernetes-sigs/cri-tools/pull/1493 (plus some other issues)
    pid=$(echo $all | yq '.info.pid')
    echo "ssh -t ${node} 'sudo nsenter -t ${pid} -n -- bash -l'"
    ssh -t $node 'sudo nsenter -t '$pid' -n -- bash -l'
    ;;
  l)
    echo $a
    echo "kubectl logs -f -n ${pod[1]} ${pod[2]}"
    kubectl logs -f -n ${pod[1]} ${pod[2]}
    ;;
  c)
    kubectl config use-context $2
    ;;
  certs)
    ssh $2 "timeout 1 openssl s_client -connect 127.0.0.1:10257 -showcerts 2>&1 | grep -A 19 -m 1 'BEGIN CERTIFICATE' | sudo tee /var/lib/rancher/rke2/server/tls/kube-controller-manager/kube-controller-manager.crt & timeout 1 openssl s_client -connect 127.0.0.1:10259 -showcerts 2>&1 | grep -A 19 -m 1 'BEGIN CERTIFICATE' | sudo tee /var/lib/rancher/rke2/server/tls/kube-scheduler/kube-scheduler.crt &"
    ;;
  ceph)
    case "$2" in
    archive)
      kubectl rook-ceph ceph crash ls | grep -v '^ID' | awk '{print $1}' | xargs -L 1 kubectl rook-ceph ceph crash archive
      ;;
    *)
      kubectl rook-ceph "$@"
      ;;
    esac
    ;;
  rados)
    kubectl rook-ceph "$@"
    ;;
  fix-rbd)
    if echo "$2" | grep -q 'csi-vol'; then
      if [ -z "$CEPH_RBD_CSI_NAMESPACE" ]; then
        rbdpods=$(kubectl get pods -A -o=jsonpath='{range .items[*]}{.metadata.namespace} {.metadata.name}{"\n"}{end}' | grep ceph | grep rbd | grep -v provisioner)
      else
        rbdpods=$(kubectl get pods -n $CEPH_RBD_CSI_NAMESPACE -o=jsonpath='{range .items[*]}{.metadata.namespace} {.metadata.name}{"\n"}{end}' | grep ceph | grep rbd | grep -v provisioner)
      fi
      while IFS= read -r p; do
        ns=$(echo $p | awk '{print $1}')
        pod=$(echo $p | awk '{print $2}')
        rbddevices=$(kubectl exec -n $ns $pod -c csi-rbdplugin -- rbd device list)
        if echo "$rbddevices" | grep -q "$2"; then
          echo "Found a matching csi-vol."
          echo "$rbddevices" | grep "$2"
          echo "In namespace: $ns, pod: $pod"
          device=$(echo "$rbddevices" | grep "$2" | awk '{print $5}')
          echo "kubectl exec -n $ns $pod -c csi-rbdplugin -- umount $device"
          kubectl exec -n $ns $pod -c csi-rbdplugin -- umount $device
          echo "kubectl exec -n $ns $pod -c csi-rbdplugin -- rbd unmap $device"
          kubectl exec -n $ns $pod -c csi-rbdplugin -- rbd unmap $device
        fi
      done <<<"$rbdpods"
    else
      echo "No csi-vol specified to unmount/unmap. Exiting. (format should be: k fix-rbd csi-vol-0d5d469e-4842-4c07-a0b8-42fbaed7b4f9)"
    fi
    ;;
  finalize)
    case "$2" in
    help)
      echo "finalize <kind> [-A] [-n <namespace>] [-l <label>]"
      echo "This removes any finalizers from the resource with kubectl patch <kind> -n <namespace> <name> -p '{\"metadata\":{\"finalizers\":null}}'"
      ;;
    *)
      resources="$(kubectl get ${@:2} -o json | jq -r '.items[] | .kind|=ascii_downcase | "\(.kind) -n \(.metadata.namespace) \(.metadata.name)"')"
      finalizers='{"metadata":{"finalizers":null}}'
      echo "$resources" | while IFS= read -r resource; do
        read -A args <<<"$resource"
        echo "kubectl patch ${args[@]} -p '$finalizers' --type=merge"
        kubectl patch "${args[@]}" -p $finalizers --type=merge &
      done
      wait
      ;;
    esac
    ;;
  node)
    kubectl run node-debug \
      --rm -it \
      --image=$DEBUG_IMAGE \
      --overrides='{"apiVersion": "v1", "spec": {"nodeName": "'$2'","hostNetwork": true,"hostPID": true,"containers": [{"name": "ubuntu","image": "'$DEBUG_IMAGE'","stdin": true,"tty": true}]}}' \
      -- bash
    ;;
  esac
}
