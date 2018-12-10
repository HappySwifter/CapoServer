import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {

    let bearer = router.grouped(User.tokenAuthMiddleware())
    let imageUploader = ImageUploader()
    bearer.post("image", use: imageUploader.uploadImage)

}
