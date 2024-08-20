class RoundedCorners {
  final bool topLeft;
  final bool topRight;
  final bool bottomLeft;
  final bool bottomRight;

  const RoundedCorners.only({
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
  });

  const RoundedCorners.left()
      : this.only(
          topLeft: true,
          bottomLeft: true,
        );

  const RoundedCorners.right()
      : this.only(
          topRight: true,
          bottomRight: true,
        );

  const RoundedCorners.top()
      : this.only(
          topLeft: true,
          topRight: true,
        );

  const RoundedCorners.bottom()
      : this.only(
          bottomLeft: true,
          bottomRight: true,
        );

  const RoundedCorners.all()
      : this.only(
          topLeft: true,
          topRight: true,
          bottomLeft: true,
          bottomRight: true,
        );
}
