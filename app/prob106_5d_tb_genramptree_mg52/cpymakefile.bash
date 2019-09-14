#!/bin/bash 
for x in `ls -b GNUmakefile*`;  
do
  for a in `cat $x | grep "#dirname=" | sed 's/#dirname=//g'`;
  do
    #echo $a 
    case "$a" in
     orig_ywadf_nadf_ntypes_ncons_nwhatn)
      cp -vf $x ./orig_ywadf_nadf_ntypes_ncons_nwhatn/GNUmakefile
     ;;
     orig_ywadf_yadf_ntypes_ncons_nwhatn)
      cp -vf $x ./orig_ywadf_yadf_ntypes_ncons_nwhatn/GNUmakefile
     ;;
     cgp2p1_nwadf_nadf_ntypes_ncons_nwhatn)
      cp -vf $x ./cgp2p1_nwadf_nadf_ntypes_ncons_nwhatn/GNUmakefile
     ;;
     cgp2p1_nwadf_nadf_ntypes_ycons_nwhatn)
      cp -vf $x ./cgp2p1_nwadf_nadf_ntypes_ycons_nwhatn/GNUmakefile
     ;;
     cgp2p1_nwadf_nadf_ytypes_ncons_nwhatn)
      cp -vf $x ./cgp2p1_nwadf_nadf_ytypes_ncons_nwhatn/GNUmakefile
     ;;
     cgp2p1_nwadf_nadf_ytypes_ycons_nwhatn)
      cp -vf $x ./cgp2p1_nwadf_nadf_ytypes_ycons_nwhatn/GNUmakefile
     ;;
     cgpf2p1_ywadf_nadf_ntypes_ncons_nwhatn)
      cp -vf $x ./cgpf2p1_ywadf_nadf_ntypes_ncons_nwhatn/GNUmakefile
     ;;
     cgpf2p1_ywadf_nadf_ntypes_ycons_nwhatn)
      cp -vf $x ./cgpf2p1_ywadf_nadf_ntypes_ycons_nwhatn/GNUmakefile
     ;;
     cgpf2p1_ywadf_nadf_ytypes_ncons_nwhatn)
      cp -vf $x ./cgpf2p1_ywadf_nadf_ytypes_ncons_nwhatn/GNUmakefile
     ;;
     cgpf2p1_ywadf_nadf_ytypes_ycons_nwhatn)
      cp -vf $x ./cgpf2p1_ywadf_nadf_ytypes_ycons_nwhatn/GNUmakefile
     ;;
     cgpf2p1_ywadf_yadf_ntypes_ncons_nwhatn)
      cp -vf $x ./cgpf2p1_ywadf_yadf_ntypes_ncons_nwhatn/GNUmakefile
     ;;
     cgpf2p1_ywadf_yadf_ntypes_ycons_nwhatn)
      cp -vf $x ./cgpf2p1_ywadf_yadf_ntypes_ycons_nwhatn/GNUmakefile
     ;;
     cgpf2p1_ywadf_yadf_ytypes_ncons_nwhatn)
      cp -vf $x ./cgpf2p1_ywadf_yadf_ytypes_ncons_nwhatn/GNUmakefile
     ;;
     cgpf2p1_ywadf_yadf_ytypes_ycons_nwhatn)
      cp -vf $x ./cgpf2p1_ywadf_yadf_ytypes_ycons_nwhatn/GNUmakefile
     ;;
     acgp1p1p2_nwadf_nadf_ntypes_ncons_ywhat0)
      cp -vf $x ./acgp1p1p2_nwadf_nadf_ntypes_ncons_ywhat0/GNUmakefile
     ;;
     acgp1p1p2_nwadf_nadf_ntypes_ncons_ywhat1)
      cp -vf $x ./acgp1p1p2_nwadf_nadf_ntypes_ncons_ywhat1/GNUmakefile
     ;;
     acgp1p1p2_nwadf_nadf_ntypes_ncons_ywhat2)
      cp -vf $x ./acgp1p1p2_nwadf_nadf_ntypes_ncons_ywhat2/GNUmakefile
     ;;
     acgp1p1p2_nwadf_nadf_ntypes_ncons_ywhat3)
      cp -vf $x ./acgp1p1p2_nwadf_nadf_ntypes_ncons_ywhat3/GNUmakefile
     ;;
     acgp1p1p2_nwadf_nadf_ntypes_ycons_ywhat0)
      cp -vf $x ./acgp1p1p2_nwadf_nadf_ntypes_ycons_ywhat0/GNUmakefile
     ;;
     acgp1p1p2_nwadf_nadf_ntypes_ycons_ywhat1)
      cp -vf $x ./acgp1p1p2_nwadf_nadf_ntypes_ycons_ywhat1/GNUmakefile
     ;;
     acgp1p1p2_nwadf_nadf_ntypes_ycons_ywhat2)
      cp -vf $x ./acgp1p1p2_nwadf_nadf_ntypes_ycons_ywhat2/GNUmakefile
     ;;
     acgp1p1p2_nwadf_nadf_ntypes_ycons_ywhat3)
      cp -vf $x ./acgp1p1p2_nwadf_nadf_ntypes_ycons_ywhat3/GNUmakefile
     ;;
     acgpf2p1_ywadf_nadf_ntypes_ncons_ywhat0)
      cp -vf $x ./acgpf2p1_ywadf_nadf_ntypes_ncons_ywhat0/GNUmakefile
     ;;
     acgpf2p1_ywadf_nadf_ntypes_ycons_ywhat0)
      cp -vf $x ./acgpf2p1_ywadf_nadf_ntypes_ycons_ywhat0/GNUmakefile
     ;;
     acgpf2p1_ywadf_yadf_ntypes_ncons_ywhat0)
      cp -vf $x ./acgpf2p1_ywadf_yadf_ntypes_ncons_ywhat0/GNUmakefile
     ;;
     acgpf2p1_ywadf_yadf_ntypes_ycons_ywhat0)
      cp -vf $x ./acgpf2p1_ywadf_yadf_ntypes_ycons_ywhat0/GNUmakefile
     ;;
     acgpf2p1_ywadf_nadf_ytypes_ncons_ywhat0)
      cp -vf $x ./acgpf2p1_ywadf_nadf_ytypes_ncons_ywhat0/GNUmakefile
     ;;
     acgpf2p1_ywadf_nadf_ytypes_ycons_ywhat0)
      cp -vf $x ./acgpf2p1_ywadf_nadf_ytypes_ycons_ywhat0/GNUmakefile
     ;;
     acgpf2p1_ywadf_yadf_ytypes_ncons_ywhat0)
      cp -vf $x ./acgpf2p1_ywadf_yadf_ytypes_ncons_ywhat0/GNUmakefile
     ;;
     acgpf2p1_ywadf_yadf_ytypes_ycons_ywhat0)
      cp -vf $x ./acgpf2p1_ywadf_yadf_ytypes_ycons_ywhat0/GNUmakefile
     ;;
     acgpf2p1_ywadf_nadf_ntypes_ncons_ywhat1)
      cp -vf $x ./acgpf2p1_ywadf_nadf_ntypes_ncons_ywhat1/GNUmakefile
     ;;
     acgpf2p1_ywadf_nadf_ntypes_ycons_ywhat1)
      cp -vf $x ./acgpf2p1_ywadf_nadf_ntypes_ycons_ywhat1/GNUmakefile
     ;;
     acgpf2p1_ywadf_yadf_ntypes_ncons_ywhat1)
      cp -vf $x ./acgpf2p1_ywadf_yadf_ntypes_ncons_ywhat1/GNUmakefile
     ;;
     acgpf2p1_ywadf_yadf_ntypes_ycons_ywhat1)
      cp -vf $x ./acgpf2p1_ywadf_yadf_ntypes_ycons_ywhat1/GNUmakefile
     ;;
     acgpf2p1_ywadf_nadf_ytypes_ncons_ywhat1)
      cp -vf $x ./acgpf2p1_ywadf_nadf_ytypes_ncons_ywhat1/GNUmakefile
     ;;
     acgpf2p1_ywadf_nadf_ytypes_ycons_ywhat1)
      cp -vf $x ./acgpf2p1_ywadf_nadf_ytypes_ycons_ywhat1/GNUmakefile
     ;;
     acgpf2p1_ywadf_yadf_ytypes_ncons_ywhat1)
      cp -vf $x ./acgpf2p1_ywadf_yadf_ytypes_ncons_ywhat1/GNUmakefile
     ;;
     acgpf2p1_ywadf_yadf_ytypes_ycons_ywhat1)
      cp -vf $x ./acgpf2p1_ywadf_yadf_ytypes_ycons_ywhat1/GNUmakefile
     ;;
     acgpf2p1_ywadf_nadf_ntypes_ncons_ywhat2)
      cp -vf $x ./acgpf2p1_ywadf_nadf_ntypes_ncons_ywhat2/GNUmakefile
     ;;
     acgpf2p1_ywadf_nadf_ntypes_ycons_ywhat2)
      cp -vf $x ./acgpf2p1_ywadf_nadf_ntypes_ycons_ywhat2/GNUmakefile
     ;;
     acgpf2p1_ywadf_yadf_ntypes_ncons_ywhat2)
      cp -vf $x ./acgpf2p1_ywadf_yadf_ntypes_ncons_ywhat2/GNUmakefile
     ;;
     acgpf2p1_ywadf_yadf_ntypes_ycons_ywhat2)
      cp -vf $x ./acgpf2p1_ywadf_yadf_ntypes_ycons_ywhat2/GNUmakefile
     ;;
     acgpf2p1_ywadf_nadf_ytypes_ncons_ywhat2)
      cp -vf $x ./acgpf2p1_ywadf_nadf_ytypes_ncons_ywhat2/GNUmakefile
     ;;
     acgpf2p1_ywadf_nadf_ytypes_ycons_ywhat2)
      cp -vf $x ./acgpf2p1_ywadf_nadf_ytypes_ycons_ywhat2/GNUmakefile
     ;;
     acgpf2p1_ywadf_yadf_ytypes_ncons_ywhat2)
      cp -vf $x ./acgpf2p1_ywadf_yadf_ytypes_ncons_ywhat2/GNUmakefile
     ;;
     acgpf2p1_ywadf_yadf_ytypes_ycons_ywhat2)
      cp -vf $x ./acgpf2p1_ywadf_yadf_ytypes_ycons_ywhat2/GNUmakefile
     ;;
     acgpf2p1_ywadf_nadf_ntypes_ncons_ywhat3)
      cp -vf $x ./acgpf2p1_ywadf_nadf_ntypes_ncons_ywhat3/GNUmakefile
     ;;
     acgpf2p1_ywadf_nadf_ntypes_ycons_ywhat3)
      cp -vf $x ./acgpf2p1_ywadf_nadf_ntypes_ycons_ywhat3/GNUmakefile
     ;;
     acgpf2p1_ywadf_yadf_ntypes_ncons_ywhat3)
      cp -vf $x ./acgpf2p1_ywadf_yadf_ntypes_ncons_ywhat3/GNUmakefile
     ;;
     acgpf2p1_ywadf_yadf_ntypes_ycons_ywhat3)
      cp -vf $x ./acgpf2p1_ywadf_yadf_ntypes_ycons_ywhat3/GNUmakefile
     ;;
     acgpf2p1_ywadf_nadf_ytypes_ncons_ywhat3)
      cp -vf $x ./acgpf2p1_ywadf_nadf_ytypes_ncons_ywhat3/GNUmakefile
     ;;
     acgpf2p1_ywadf_nadf_ytypes_ycons_ywhat3)
      cp -vf $x ./acgpf2p1_ywadf_nadf_ytypes_ycons_ywhat3/GNUmakefile
     ;;
     acgpf2p1_ywadf_yadf_ytypes_ncons_ywhat3)
      cp -vf $x ./acgpf2p1_ywadf_yadf_ytypes_ncons_ywhat3/GNUmakefile
     ;;
     acgpf2p1_ywadf_yadf_ytypes_ycons_ywhat3)
      cp -vf $x ./acgpf2p1_ywadf_yadf_ytypes_ycons_ywhat3/GNUmakefile
     ;;
    esac
  done;
done;
