package kuzovkov.cursval;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.DialogFragment;
import android.content.DialogInterface;
import android.os.Bundle;
import android.util.Log;

/**
 * Created by sania on 3/19/2015.
 */
public class NoticeDialogFragment extends DialogFragment {
    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState){
        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
        builder.setTitle(getResources().getString(R.string.app_name));
        builder.setMessage(getResources().getString(R.string.load_valutes_fail));

        builder.setPositiveButton(getResources().getString(R.string.repeat), new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int id) {
               mListener.onDialogPositiveClick(NoticeDialogFragment.this);
            }
        });

        builder.setNegativeButton(getResources().getString(R.string.close_app), new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int id) {
               mListener.onDialogNegativeClick(NoticeDialogFragment.this);
            }
        });

        builder.setCancelable(false);
        return builder.create();
    }

    public interface NoticeDialogListener{
        public void onDialogPositiveClick(DialogFragment dialog);
        public  void onDialogNegativeClick(DialogFragment dialog);
    }

    NoticeDialogListener mListener;

    @Override
    public void onAttach(Activity activity){
        super.onAttach(activity);
        try{
            mListener = (NoticeDialogListener) activity;
        }catch(ClassCastException e){
            throw new ClassCastException( activity.toString()+" must implement NoticeDialogListener");
        }
    }

}
