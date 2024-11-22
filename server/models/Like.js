import { Schema, model } from 'mongoose';

const likeSchema = new Schema({
  postId: { type: Schema.Types.ObjectId, ref: 'Post', required: true },
  userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
}, { timestamps: true });

const Like = model('Like', likeSchema);

export default Like;
